import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/exam_status.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/firebase_error_messages.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';
import 'package:mrmichaelashrafdashboard/features/home/logic/home_state.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_record_status.dart';
import 'package:mrmichaelashrafdashboard/features/payments/data/models/payment_record.dart';
import 'package:mrmichaelashrafdashboard/features/users/logic/users_cubit.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> load() async {
    emit(const LoadHomeLoading());
    try {
      final bundle = await _fetchBundle();
      emit(
        LoadHomeSuccess(
          topCourses: bundle.topCourses,
          liveExams: bundle.liveExams,
          liveHighlights: bundle.liveHighlights,
          pendingPayments: bundle.pendingPayments,
          breakdown: bundle.breakdown,
          totalCoursesCount: bundle.totalCoursesCount,
          totalExamsCount: bundle.totalExamsCount,
          activeExamsCount: bundle.liveExams.length,
          totalHighlightsCount: bundle.totalHighlightsCount,
          activeHighlightsCount: bundle.liveHighlights.length,
          totalEnrollmentsCount: bundle.totalEnrollmentsCount,
          totalRevenue: bundle.totalRevenue,
        ),
      );
    } catch (e) {
      emit(
        LoadHomeError(
          FirebaseErrorTranslator.translate(
            e,
            fallback: AppStrings.errors.courseLoadFailed,
          ).message,
        ),
      );
    }
  }

  Future<void> refresh() async {
    final current = state;
    if (current is LoadHomeSuccess) {
      emit(RefreshHomeLoading(current));
    } else {
      emit(const LoadHomeLoading());
    }
    try {
      final bundle = await _fetchBundle();
      emit(
        RefreshHomeSuccess(
          topCourses: bundle.topCourses,
          liveExams: bundle.liveExams,
          liveHighlights: bundle.liveHighlights,
          pendingPayments: bundle.pendingPayments,
          breakdown: bundle.breakdown,
          totalCoursesCount: bundle.totalCoursesCount,
          totalExamsCount: bundle.totalExamsCount,
          activeExamsCount: bundle.liveExams.length,
          totalHighlightsCount: bundle.totalHighlightsCount,
          activeHighlightsCount: bundle.liveHighlights.length,
          totalEnrollmentsCount: bundle.totalEnrollmentsCount,
          totalRevenue: bundle.totalRevenue,
        ),
      );
      // Settle back into the canonical success state so subsequent reads of
      // `state is LoadHomeSuccess` keep working uniformly.
      if (!isClosed) {
        emit(
          LoadHomeSuccess(
            topCourses: bundle.topCourses,
            liveExams: bundle.liveExams,
            liveHighlights: bundle.liveHighlights,
            pendingPayments: bundle.pendingPayments,
            breakdown: bundle.breakdown,
            totalCoursesCount: bundle.totalCoursesCount,
            totalExamsCount: bundle.totalExamsCount,
            activeExamsCount: bundle.liveExams.length,
            totalHighlightsCount: bundle.totalHighlightsCount,
            activeHighlightsCount: bundle.liveHighlights.length,
            totalEnrollmentsCount: bundle.totalEnrollmentsCount,
            totalRevenue: bundle.totalRevenue,
          ),
        );
      }
    } catch (e) {
      emit(
        RefreshHomeError(
          FirebaseErrorTranslator.translate(
            e,
            fallback: AppStrings.errors.courseLoadFailed,
          ).message,
        ),
      );
    }
  }

  Future<_HomeBundle> _fetchBundle() async {
    final results = await Future.wait([
      _fetchTopCourses(limit: 3), // 0
      _fetchAllExams(), // 1
      _fetchActiveHighlights(), // 2
      _fetchUsersBreakdown(), // 3
      _getCoursesCount(), // 4
      _computeConfirmedRevenue(), // 5
      _getTotalEnrollmentsCount(), // 6
    ]);

    final exams = results[1] as List<Exam>;
    final highlights = results[2] as List<Highlight>;

    final liveExams = exams
        .where(
          (e) => (e.state ?? e.computeUserExamState()) == ExamStatus.active,
        )
        .toList();
    final liveHighlights = highlights.where((h) => h.isActive()).toList();

    return _HomeBundle(
      topCourses: results[0] as List<Course>,
      liveExams: liveExams,
      liveHighlights: liveHighlights,
      // Pending payments are no longer fetched for the home preview — the
      // payments collection isn't populated yet. Keep an empty list so the
      // bundle shape stays stable.
      pendingPayments: const [],
      breakdown: results[3] as UsersBreakdown,
      totalCoursesCount: results[4] as int,
      totalExamsCount: exams.length,
      totalHighlightsCount: highlights.length,
      totalEnrollmentsCount: results[6] as int,
      totalRevenue: results[5] as double,
    );
  }

  /// Sum aggregation of `enrollmentCount` across all course docs. One read,
  /// runs server-side. Surfaces the platform-wide "total students signed up
  /// for a course" number used by the home analytics grid.
  Future<int> _getTotalEnrollmentsCount() async {
    try {
      final agg = await _firestore
          .collection('courses')
          .aggregate(sum('enrollmentCount'))
          .get();
      return (agg.getSum('enrollmentCount') ?? 0).toInt();
    } catch (_) {
      return 0;
    }
  }

  Future<List<Course>> _fetchTopCourses({required int limit}) async {
    final snap = await _firestore
        .collection('courses')
        .orderBy('enrollmentCount', descending: true)
        .limit(limit)
        .get();
    return snap.docs
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
  }

  Future<int> _getCoursesCount() async {
    final agg = await _firestore.collection('courses').count().get();
    return agg.count ?? 0;
  }

  Future<List<Exam>> _fetchAllExams() async {
    final snap = await _firestore.collection('exams').get();
    return snap.docs
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
  }

  Future<List<Highlight>> _fetchActiveHighlights() async {
    final snap = await _firestore.collection('highlights').get();
    return snap.docs
        .map((doc) {
          try {
            return Highlight.fromJson(doc.data(), id: doc.id);
          } catch (_) {
            return null;
          }
        })
        .whereType<Highlight>()
        .toList();
  }

  Future<UsersBreakdown> _fetchUsersBreakdown() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      var total = 0,
          online = 0,
          center = 0,
          male = 0,
          female = 0,
          unverified = 0;
      for (final doc in snapshot.docs) {
        total++;
        final data = doc.data();
        switch (data['studyType']) {
          case 'onlineStudent':
            online++;
          case 'centerStudent':
            center++;
        }
        switch (data['gender']) {
          case 'male':
            male++;
          case 'female':
            female++;
        }
        if (data['emailVerified'] != true) unverified++;
      }
      return UsersBreakdown(
        total: total,
        online: online,
        center: center,
        male: male,
        female: female,
        unverified: unverified,
        verified: total - unverified,
      );
    } catch (_) {
      return const UsersBreakdown.empty();
    }
  }

  Future<double> _computeConfirmedRevenue() async {
    try {
      final snap = await _firestore
          .collection('payments')
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
}

class _HomeBundle {
  final List<Course> topCourses;
  final List<Exam> liveExams;
  final List<Highlight> liveHighlights;
  final List<PaymentRecord> pendingPayments;
  final UsersBreakdown breakdown;
  final int totalCoursesCount;
  final int totalExamsCount;
  final int totalHighlightsCount;
  final int totalEnrollmentsCount;
  final double totalRevenue;

  const _HomeBundle({
    required this.topCourses,
    required this.liveExams,
    required this.liveHighlights,
    required this.pendingPayments,
    required this.breakdown,
    required this.totalCoursesCount,
    required this.totalExamsCount,
    required this.totalHighlightsCount,
    required this.totalEnrollmentsCount,
    required this.totalRevenue,
  });
}
