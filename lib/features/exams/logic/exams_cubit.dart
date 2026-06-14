import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/firebase_error_messages.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam_result.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/exams_state.dart';
import 'package:mrmichaelashrafdashboard/features/users/data/models/app_user.dart';

class ExamsCubit extends Cubit<ExamsState> {
  ExamsCubit() : super(const ExamsInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── publishExam ────────────────────────────────────────────────────────
  Future<void> publishExam({required Exam exam}) async {
    emit(const PublishExamLoading());
    try {
      await _firestore.collection('exams').doc(exam.examID).set(exam.toMap());
      emit(PublishExamSuccess(exam));
    } catch (e) {
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.examPublishFailed,
      );
      emit(PublishExamError(translated.message));
    }
  }

  // ─── saveExamUpdates ────────────────────────────────────────────────────
  Future<void> saveExamUpdates({required Exam exam}) async {
    emit(const SaveExamUpdatesLoading());
    try {
      await _firestore
          .collection('exams')
          .doc(exam.examID)
          .set(exam.toMap(), SetOptions(merge: true));
      emit(SaveExamUpdatesSuccess(exam));
    } catch (e) {
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.examUpdateFailed,
      );
      emit(SaveExamUpdatesError(translated.message));
    }
  }

  // ─── deleteExam ─────────────────────────────────────────────────────────
  Future<void> deleteExam({required String examId}) async {
    emit(const DeleteExamLoading());
    try {
      await _firestore.collection('exams').doc(examId).delete();
      emit(DeleteExamSuccess(examId));
    } catch (e) {
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.examDeleteFailed,
      );
      emit(DeleteExamError(translated.message));
    }
  }

  // ─── toggleExamVisibility (NEW — implementation pending) ───────────────
  /// Flips the admin-controlled `isVisible` flag. Exams are created hidden
  /// (`isVisible: false`) so the teacher reviews before publishing to students.
  Future<void> toggleExamVisibility({
    required String examId,
    required bool isVisible,
  }) async {
    emit(ToggleExamVisibilityLoading(examId));
    try {
      await _firestore.collection('exams').doc(examId).update({
        'isVisible': isVisible,
      });
      emit(ToggleExamVisibilitySuccess(examId: examId, isVisible: isVisible));
    } catch (e) {
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.examUpdateFailed,
      );
      emit(ToggleExamVisibilityError(translated.message));
    }
  }

  // ─── fetchExamsPage (Future-returning helper) ──────────────────────────
  // The center owns its page list + loading/error UI, so this returns the
  // slice directly and does not emit.
  Future<List<Exam>> fetchExamsPage({
    required int page,
    required int pageSize,
    String? gradeName,
  }) async {
    Query<Map<String, dynamic>> q = _firestore.collection('exams');
    if (gradeName != null) {
      // Grade-filtered: skip the server-side orderBy to avoid needing a
      // (grade + startTime) composite index — sorted in memory below.
      q = q.where('grade', isEqualTo: gradeName);
    } else {
      q = q.orderBy('startTime', descending: true);
    }
    final snap = await q.limit(page * pageSize).get();

    final allDocs = snap.docs;
    final skip = (page - 1) * pageSize;
    final pageDocs = skip >= allDocs.length
        ? const <QueryDocumentSnapshot<Map<String, dynamic>>>[]
        : allDocs.sublist(skip);

    final exams = pageDocs
        .map((doc) {
          try {
            final data = doc.data();
            data['id'] = doc.id;
            return Exam.fromMap(data);
          } catch (_) {
            return null;
          }
        })
        .whereType<Exam>()
        .toList();
    // Newest-first; exams without a startTime sort to the end.
    exams.sort((a, b) {
      if (a.startTime == null && b.startTime == null) return 0;
      if (a.startTime == null) return 1;
      if (b.startTime == null) return -1;
      return b.startTime!.compareTo(a.startTime!);
    });
    return exams;
  }

  // ─── fetchExamResults (Future-returning helper) ─────────────────────────
  // The results sheet awaits this inline and renders its own loading /
  // error UI, so the cubit doesn't emit. The matching `FetchExamResults*`
  // state triples in exams_state.dart are reserved for the day a
  // screen wants to observe the lifecycle instead.
  //
  // Reads the flat top-level `exam_results` collection (the student app's
  // write target) filtered by examID. Doc IDs are composite
  // `{examID}_{studentID}` so we trust the in-doc `studentID` field instead
  // of the doc id.
  Future<List<ExamResult>> fetchExamResults(String examId) async {
    final snap = await _firestore
        .collection('exam_results')
        .where('examID', isEqualTo: examId)
        .get();

    return snap.docs
        .map((doc) {
          try {
            final data = doc.data();
            data['submittedAt'] = data['submittedAt'] is Timestamp
                ? (data['submittedAt'] as Timestamp).millisecondsSinceEpoch
                : data['submittedAt'];
            return ExamResult.fromMap({...data, 'resultID': doc.id});
          } catch (_) {
            return null;
          }
        })
        .whereType<ExamResult>()
        .toList()
      ..sort((a, b) {
        if (a.submittedAt != null && b.submittedAt != null) {
          return b.submittedAt!.compareTo(a.submittedAt!);
        }
        return (b.score ?? 0).compareTo(a.score ?? 0);
      });
  }

  // ─── Helpers (no state emit) ────────────────────────────────────────────

  Future<int> getExamsCount({String? gradeName}) async {
    Query<Map<String, dynamic>> q = _firestore.collection('exams');
    if (gradeName != null) {
      q = q.where('grade', isEqualTo: gradeName);
    }
    final agg = await q.count().get();
    return agg.count ?? 0;
  }

  /// One COUNT aggregation per exam — cheap (~1 doc read each regardless of
  /// how many students took it). The center batches these in parallel for a
  /// page of exams; results plug into [ExamCard.finishedUsersCount].
  Future<int> fetchExamResultsCount(String examId) async {
    try {
      final agg = await _firestore
          .collection('exam_results')
          .where('examID', isEqualTo: examId)
          .count()
          .get();
      return agg.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<Exam?> fetchExamById(String examId) async {
    final snap = await _firestore.collection('exams').doc(examId).get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    data['id'] = snap.id;
    return Exam.fromMap(data);
  }

  /// All results belonging to a single student, newest-first. Powers the
  /// "الامتحانات المؤداة" section of the user sheet.
  Future<List<ExamResult>> fetchResultsByUser(String userId) async {
    final snap = await _firestore
        .collection('exam_results')
        .where('studentID', isEqualTo: userId)
        .get();
    return snap.docs
        .map((doc) {
          try {
            final data = doc.data();
            data['submittedAt'] = data['submittedAt'] is Timestamp
                ? (data['submittedAt'] as Timestamp).millisecondsSinceEpoch
                : data['submittedAt'];
            return ExamResult.fromMap({...data, 'resultID': doc.id});
          } catch (_) {
            return null;
          }
        })
        .whereType<ExamResult>()
        .toList()
      ..sort((a, b) {
        if (a.submittedAt != null && b.submittedAt != null) {
          return b.submittedAt!.compareTo(a.submittedAt!);
        }
        return 0;
      });
  }

  /// Hydrate exam docs by ID — paired with [fetchResultsByUser] so the user
  /// sheet can show exam metadata next to each result.
  Future<List<Exam>> fetchExamsByIds(List<String> examIds) async {
    if (examIds.isEmpty) return const [];
    const batchSize = 30;
    final results = <Exam>[];
    for (var i = 0; i < examIds.length; i += batchSize) {
      final slice = examIds.sublist(
        i,
        (i + batchSize).clamp(0, examIds.length),
      );
      final snap = await _firestore
          .collection('exams')
          .where(FieldPath.documentId, whereIn: slice)
          .get();
      for (final doc in snap.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          results.add(Exam.fromMap(data));
        } catch (_) {}
      }
    }
    return results;
  }

  /// Batched lookup of student display name + email for the exam-results
  /// sheet. Uses `whereIn` (Firestore caps at 30 per query) so a single page
  /// of results stays at O(ceil(N/30)) reads instead of N parallel single-doc
  /// gets. Missing students fall back to the localized "unknown student"
  /// label so the sheet never renders blank rows.
  Future<({Map<String, String> names, Map<String, String> emails})>
  fetchUserNamesAndEmails(List<String> userIds) async {
    final names = <String, String>{};
    final emails = <String, String>{};
    if (userIds.isEmpty) return (names: names, emails: emails);

    const batchSize = 30;
    try {
      for (var i = 0; i < userIds.length; i += batchSize) {
        final slice = userIds.sublist(
          i,
          (i + batchSize).clamp(0, userIds.length),
        );
        final snap = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: slice)
            .get();
        for (final doc in snap.docs) {
          try {
            final data = doc.data();
            data['userID'] = doc.id;
            names[doc.id] = AppUser.fromJson(data).userName;
            emails[doc.id] = (data['email'] ?? '') as String;
          } catch (_) {
            names[doc.id] = 'طالب غير معروف';
            emails[doc.id] = '';
          }
        }
      }
      // Fill in any IDs the whereIn batch didn't return (deleted users etc.)
      // so the caller's UI never has to handle the "key missing" case.
      for (final id in userIds) {
        names.putIfAbsent(id, () => 'طالب غير معروف');
        emails.putIfAbsent(id, () => '');
      }
      return (names: names, emails: emails);
    } catch (_) {
      return (names: names, emails: emails);
    }
  }
}
