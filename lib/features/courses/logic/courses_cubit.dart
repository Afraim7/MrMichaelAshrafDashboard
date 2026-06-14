import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/enrollment_status.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/firebase_error_messages.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course_enrollment.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/courses_state.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_gateway.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_record_status.dart';
import 'package:mrmichaelashrafdashboard/features/payments/data/models/payment_record.dart';

/// Owns every Firestore touch under the `courses/` and `enrollments/`
/// collections that the admin dashboard makes.
///
/// State emits follow the per-action triple pattern (see
/// [courses_state.dart] for the layout). Pure helper reads — count
/// queries, lookups that screens treat as plain async — return a Future
/// directly and don't emit, keeping the cubit's state focused on
/// "did the last action complete?" rather than "what's the current list?".
/// Screen-local pagination caches handle the latter.
class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit() : super(const CoursesInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── publishCourse ──────────────────────────────────────────────────────
  Future<void> publishCourse({required Course course}) async {
    emit(const PublishCourseLoading());
    try {
      await _firestore
          .collection('courses')
          .doc(course.courseID)
          .set(course.toMap());
      emit(PublishCourseSuccess(course));
    } catch (e) {
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.coursePublishFailed,
      );
      emit(PublishCourseError(translated.message));
    }
  }

  // ─── saveCourseUpdates ──────────────────────────────────────────────────
  Future<void> saveCourseUpdates({required Course course}) async {
    emit(const SaveCourseUpdatesLoading());
    try {
      await _firestore
          .collection('courses')
          .doc(course.courseID)
          .set(course.toMap(), SetOptions(merge: true));
      emit(SaveCourseUpdatesSuccess(course));
    } catch (e) {
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.courseUpdateFailed,
      );
      emit(SaveCourseUpdatesError(translated.message));
    }
  }

  // ─── deleteCourse ───────────────────────────────────────────────────────
  Future<void> deleteCourse({required String courseId}) async {
    emit(const DeleteCourseLoading());
    try {
      await _firestore.collection('courses').doc(courseId).delete();
      emit(DeleteCourseSuccess(courseId));
    } catch (e) {
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.courseDeleteFailed,
      );
      emit(DeleteCourseError(translated.message));
    }
  }

  // ─── toggleCourseVisibility ─────────────────────────────────────────────
  /// Flips the admin-controlled `isVisible` flag. When false the course is
  /// hidden from students regardless of its date window. Courses are created
  /// hidden (`isVisible: false`) so the teacher reviews before publishing.
  Future<void> toggleCourseVisibility({
    required String courseId,
    required bool isVisible,
  }) async {
    emit(ToggleCourseVisibilityLoading(courseId));
    try {
      await _firestore.collection('courses').doc(courseId).update({
        'isVisible': isVisible,
      });
      emit(
        ToggleCourseVisibilitySuccess(courseId: courseId, isVisible: isVisible),
      );
    } catch (e) {
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.courseUpdateFailed,
      );
      emit(ToggleCourseVisibilityError(translated.message));
    }
  }

  // ─── fetchCoursesPage (Future-returning helper) ────────────────────────
  // The center owns its page list + loading/error UI, so this returns the
  // slice directly and does not emit. Offset-emulation: pull `page*pageSize`
  // rows, drop the leading ones in memory.
  Future<List<Course>> fetchCoursesPage({
    required int page,
    required int pageSize,
    String? gradeName,
  }) async {
    Query<Map<String, dynamic>> q = _firestore.collection('courses');
    if (gradeName != null) {
      // Grade-filtered: skip the server-side orderBy to avoid needing a
      // (grade + enrollmentCount) composite index — sorted in memory below.
      q = q.where('grade', isEqualTo: gradeName);
    } else {
      q = q.orderBy('enrollmentCount', descending: true);
    }
    final snap = await q.limit(page * pageSize).get();

    final allDocs = snap.docs;
    final skip = (page - 1) * pageSize;
    final pageDocs = skip >= allDocs.length
        ? const <QueryDocumentSnapshot<Map<String, dynamic>>>[]
        : allDocs.sublist(skip);

    final courses = pageDocs
        .map((doc) {
          try {
            final data = doc.data();
            data['courseID'] = doc.id;
            return Course.fromMap(data);
          } catch (_) {
            return null;
          }
        })
        .whereType<Course>()
        .toList();
    courses.sort((a, b) => b.enrollmentCount.compareTo(a.enrollmentCount));
    return courses;
  }

  // ─── Helpers (no state emit) ────────────────────────────────────────────

  Future<int> getCoursesCount({String? gradeName}) async {
    Query<Map<String, dynamic>> q = _firestore.collection('courses');
    if (gradeName != null) {
      q = q.where('grade', isEqualTo: gradeName);
    }
    final agg = await q.count().get();
    return agg.count ?? 0;
  }

  Future<Course?> fetchCourseById(String courseId) async {
    final snap = await _firestore.collection('courses').doc(courseId).get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    data['courseID'] = snap.id;
    return Course.fromMap(data);
  }

  /// Real earned revenue for a course = sum of `amount` over its SUCCESSFUL
  /// payments. Reflects what students actually paid (discounts, comps, manual
  /// amounts) — unlike `price × enrollments`, which ignores every discount and
  /// free grant. Mirrors HomeCubit's `_computeConfirmedRevenue`, scoped to one
  /// course.
  Future<double> fetchCourseRevenue(String courseId) async {
    try {
      final snap = await _firestore
          .collection('payments')
          .where('courseID', isEqualTo: courseId)
          .where('status', isEqualTo: PaymentRecordStatus.success.name)
          .get();
      var total = 0.0;
      for (final doc in snap.docs) {
        total += (doc.data()['amount'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (_) {
      return 0.0;
    }
  }

  // ─── Enrollment helpers (Future-returning; sheets await them inline) ────
  // These are intentionally not state-emitting actions: the
  // CourseEnrollmentsSheet renders its own loading / error UI while
  // awaiting each call and only needs the return value or thrown error.
  // The matching `Fetch/Enroll/CancelEnrollment(...)` state triples in
  // `courses_state.dart` are reserved for the day a screen wants to
  // observe these lifecycles instead — keep them around as architectural
  // intent.

  Future<List<CourseEnrollment>> fetchCourseEnrollments(String courseID) async {
    final snap = await _firestore
        .collection('enrollments')
        .where('courseID', isEqualTo: courseID)
        .get();
    return snap.docs
        .map((d) {
          try {
            final data = d.data();
            data['enrollmentID'] = d.id;
            return CourseEnrollment.fromMap(data);
          } catch (_) {
            return null;
          }
        })
        .whereType<CourseEnrollment>()
        .toList()
      ..sort((a, b) => b.enrolledAt.compareTo(a.enrolledAt));
  }

  /// Enrolls a student in a course — exact port of the student app's
  /// `CoursesRepoImpl.enrollInCourse`, with an email→uid lookup prepended
  /// because the admin form supplies an email rather than a uid.
  ///
  /// Same logic as the source of truth: a prior `cancelled` enrollment is
  /// REUSED (flipped back to `ready`) instead of creating a duplicate doc;
  /// an existing `active`/`ready` enrollment blocks. Lands in `ready` (the
  /// student still taps "start" to go `active`). One atomic batch bumps both
  /// the course and user counters. `amountPaid == 0` writes no payment doc.
  Future<void> enrollingAStudent({
    required String courseId,
    required String email,
    double amountPaid = 0,
    String paymentMethod = 'manual',
    String transactionID = '',
  }) async {
    // Admin enters an email; resolve it to the student's uid first.
    final lookup = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();
    if (lookup.docs.isEmpty) {
      throw 'لم نعثر على طالب بهذا البريد الإلكتروني';
    }
    final userId = lookup.docs.first.id;

    // ─── Exact port of enrollInCourse from here ──────────────────────────
    final existing = await _firestore
        .collection('enrollments')
        .where('userID', isEqualTo: userId)
        .where('courseID', isEqualTo: courseId)
        .limit(1)
        .get();

    final batch = _firestore.batch();
    final now = DateTime.now();

    DocumentReference? paymentRef;
    if (amountPaid > 0) {
      paymentRef = _firestore.collection('payments').doc();
    }

    String enrollmentId;
    DocumentReference enrollmentRef;

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final currentStatus = doc.data()['status'];

      // Any active/ready enrollment blocks; a prior cancelled one is reused.
      if (currentStatus == EnrollmentStatus.active.name ||
          currentStatus == EnrollmentStatus.ready.name) {
        throw 'هذا الطالب مسجّل بالفعل في الكورس';
      }

      enrollmentRef = doc.reference;
      enrollmentId = doc.id;

      batch.update(enrollmentRef, {
        'status': EnrollmentStatus.ready.name,
        'enrolledAt': now.toIso8601String(),
        'paymentID': paymentRef?.id,
      });
    } else {
      enrollmentRef = _firestore.collection('enrollments').doc();
      enrollmentId = enrollmentRef.id;

      final enrollment = CourseEnrollment(
        enrollmentID: enrollmentId,
        userID: userId,
        courseID: courseId,
        status: EnrollmentStatus.ready,
        enrolledAt: now,
        paymentID: paymentRef?.id,
      );

      batch.set(enrollmentRef, enrollment.toMap());
    }

    if (amountPaid > 0 && paymentRef != null) {
      final payment = PaymentRecord(
        paymentID: paymentRef.id,
        userID: userId,
        courseID: courseId,
        enrollmentID: enrollmentId,
        amount: amountPaid,
        paymentGateway: PaymentGateway.manual,
        paymentMethod: paymentMethod,
        transactionID: transactionID,
        status: PaymentRecordStatus.success,
        paidAt: now,
        createdAt: now,
      );
      batch.set(paymentRef, payment.toMap());
    }

    batch.update(_firestore.collection('courses').doc(courseId), {
      'enrollmentCount': FieldValue.increment(1),
    });

    batch.set(
      _firestore.collection('users').doc(userId),
      {'enrolledCoursesCount': FieldValue.increment(1)},
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Cancels a student's enrollment — exact port of the student app's
  /// `CoursesRepoImpl.unenrollFromCourse`. SOFT-CANCEL: the enrollment row is
  /// kept (status → `cancelled`), the payment ledger is left intact (archiving
  /// is reserved for account deletion), and `progressMap` is wiped so a future
  /// re-enroll starts fresh. Both counters are decremented, floored at 0,
  /// inside a transaction (the floor must read the current value first).
  Future<void> cancellingCourseEnrollment({
    required String userId,
    required String courseId,
  }) async {
    // Firestore transactions can't run queries, so resolve the doc ref first.
    final enrollmentSnap = await _firestore
        .collection('enrollments')
        .where('userID', isEqualTo: userId)
        .where('courseID', isEqualTo: courseId)
        .limit(1)
        .get();

    if (enrollmentSnap.docs.isEmpty) {
      throw 'لم نجد اشتراكاً نشطاً لهذا الطالب في هذا الكورس.';
    }
    final enrollmentRef = enrollmentSnap.docs.first.reference;

    final courseRef = _firestore.collection('courses').doc(courseId);
    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((tx) async {
      // ── Reads first (transactions forbid reads after any write) ──
      final courseSnap = await tx.get(courseRef);
      final userSnap = await tx.get(userRef);
      final courseCount =
          (courseSnap.data()?['enrollmentCount'] as num?)?.toInt() ?? 0;
      final userCount =
          (userSnap.data()?['enrolledCoursesCount'] as num?)?.toInt() ?? 0;

      // ── Writes ──
      tx.update(enrollmentRef, {
        'status': EnrollmentStatus.cancelled.name,
        'progressMap': <String, dynamic>{},
        'completedAt': null,
      });

      if (courseSnap.exists) {
        tx.update(courseRef, {
          'enrollmentCount': courseCount > 0 ? courseCount - 1 : 0,
        });
      }
      tx.set(userRef, {
        'enrolledCoursesCount': userCount > 0 ? userCount - 1 : 0,
      }, SetOptions(merge: true));
    });
  }

  /// All enrollments belonging to a single student, newest-first. Powers the
  /// "الكورسات المسجلة" section of the user sheet.
  Future<List<CourseEnrollment>> fetchEnrollmentsByUser(String userID) async {
    final snap = await _firestore
        .collection('enrollments')
        .where('userID', isEqualTo: userID)
        .get();
    return snap.docs
        .map((d) {
          try {
            final data = d.data();
            data['enrollmentID'] = d.id;
            return CourseEnrollment.fromMap(data);
          } catch (_) {
            return null;
          }
        })
        .whereType<CourseEnrollment>()
        .toList()
      ..sort((a, b) => b.enrolledAt.compareTo(a.enrolledAt));
  }

  /// Hydrate a small list of `Course` docs by ID (caller already has the IDs
  /// from a prior enrollments query). Uses `whereIn` batches of 30 — Firestore's
  /// per-query limit — so up to ~30 IDs at once is a single round-trip.
  Future<List<Course>> fetchCoursesByIds(List<String> courseIds) async {
    if (courseIds.isEmpty) return const [];
    const batchSize = 30;
    final results = <Course>[];
    for (var i = 0; i < courseIds.length; i += batchSize) {
      final slice = courseIds.sublist(
        i,
        (i + batchSize).clamp(0, courseIds.length),
      );
      final snap = await _firestore
          .collection('courses')
          .where(FieldPath.documentId, whereIn: slice)
          .get();
      for (final doc in snap.docs) {
        try {
          final data = doc.data();
          data['courseID'] = doc.id;
          results.add(Course.fromMap(data));
        } catch (_) {}
      }
    }
    return results;
  }
}
