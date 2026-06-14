import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_gateway.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_record_status.dart';
import 'package:mrmichaelashrafdashboard/features/payments/data/models/payment_record.dart';
import 'package:mrmichaelashrafdashboard/features/payments/logic/payments_state.dart';

/// Lightweight summary used by the analytics section.
class PaymentStats {
  final double totalRevenueLifetime;
  final double totalRevenueThisMonth;
  final int pendingCount;
  final int confirmedCount;
  final int failedCount;
  final int refundedCount;
  final String? topCourseTitle;
  final double topCourseRevenue;

  const PaymentStats({
    required this.totalRevenueLifetime,
    required this.totalRevenueThisMonth,
    required this.pendingCount,
    required this.confirmedCount,
    required this.failedCount,
    required this.refundedCount,
    this.topCourseTitle,
    this.topCourseRevenue = 0,
  });

  double get confirmedRatio {
    final total = pendingCount + confirmedCount + failedCount + refundedCount;
    if (total == 0) return 0;
    return confirmedCount / total;
  }
}

/// Cubit for the payments center.
///
/// Owns Firestore reads against the `payments`, `users`, and `courses`
/// collections. Read-only — admins browse + inspect; there are no
/// confirm/reject/refund actions in the dashboard.
///
/// State emits follow the per-action triple pattern (see [payments_state]).
/// Helper reads (single-user history, stats) return a Future directly and
/// don't emit; the call sites await them inline.
class PaymentsCubit extends Cubit<PaymentsState> {
  PaymentsCubit() : super(const PaymentsInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const int _kWhereInBatch = 30; // Firestore's whereIn cap.

  // ─── fetchPaymentsPage ──────────────────────────────────────────────────
  /// One page of payments, sorted newest-first by `paidAt`, optionally
  /// filtered by [gateway]. Resolves student names + course titles from the
  /// `users` / `courses` collections in batched whereIn queries so the UI
  /// renders display labels without doing per-row reads.
  ///
  /// Pagination mirrors the other centers: `.limit(page * pageSize).get()`
  /// then in-memory `sublist` for the requested page. Cheap at the scales
  /// the dashboard runs at; swap for cursor-based if the payments list ever
  /// grows past a few thousand rows.
  Future<void> fetchPaymentsPage({
    required int page,
    required int pageSize,
    PaymentGateway? gateway,
  }) async {
    emit(const FetchPaymentsLoading());
    try {
      Query<Map<String, dynamic>> q = _firestore.collection('payments');
      if (gateway != null) {
        // Gateway-filtered: skip the server-side orderBy to avoid a composite
        // index. Sorted in memory below.
        q = q.where('paymentGateway', isEqualTo: gateway.name);
      } else {
        q = q.orderBy('paidAt', descending: true);
      }

      // Pull `page * pageSize` rows total + a separate aggregation for the
      // grand total so the pagination bar knows how many pages exist.
      final results = await Future.wait([
        q.limit(page * pageSize).get(),
        gateway == null
            ? _firestore.collection('payments').count().get()
            : _firestore
                .collection('payments')
                .where('paymentGateway', isEqualTo: gateway.name)
                .count()
                .get(),
      ]);
      final snap = results[0] as QuerySnapshot<Map<String, dynamic>>;
      final totalCount =
          ((results[1] as AggregateQuerySnapshot).count) ?? 0;

      var payments = snap.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['paymentID'] = doc.id;
              return PaymentRecord.fromMap(data);
            } catch (_) {
              return null;
            }
          })
          .whereType<PaymentRecord>()
          .toList();

      if (gateway != null) {
        payments.sort((a, b) => b.paidAt.compareTo(a.paidAt));
      }

      final skip = (page - 1) * pageSize;
      final pageItems = skip >= payments.length
          ? const <PaymentRecord>[]
          : payments.sublist(skip, (skip + pageSize).clamp(0, payments.length));

      // Resolve display labels for just the rows we're about to render.
      final userIds =
          pageItems.map((p) => p.userID).where((id) => id.isNotEmpty).toSet();
      final courseIds =
          pageItems.map((p) => p.courseID).where((id) => id.isNotEmpty).toSet();
      final lookups = await Future.wait([
        _fetchUserNames(userIds.toList()),
        _fetchCourseTitles(courseIds.toList()),
      ]);

      emit(
        FetchPaymentsSuccess(
          payments: pageItems,
          page: page,
          pageSize: pageSize,
          totalCount: totalCount,
          userNamesMap: lookups[0],
          courseTitlesMap: lookups[1],
        ),
      );
    } catch (_) {
      emit(const FetchPaymentsError('تعذّر تحميل المدفوعات، حاول مجددًا'));
    }
  }

  /// All of a single student's payments, newest-first. Read-only — used by
  /// the user sheet's "confirmed payments" section.
  Future<List<PaymentRecord>> fetchPaymentsByUser(String userId) async {
    try {
      final snap = await _firestore
          .collection('payments')
          .where('userID', isEqualTo: userId)
          .get();
      final payments = snap.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['paymentID'] = doc.id;
              return PaymentRecord.fromMap(data);
            } catch (_) {
              return null;
            }
          })
          .whereType<PaymentRecord>()
          .toList()
        ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
      return payments;
    } catch (_) {
      return const [];
    }
  }

  /// Aggregate stats across the WHOLE `payments` collection. Pulls every doc
  /// in one shot (no pagination) — fine at the scale we're targeting; if the
  /// collection grows past a few thousand rows, swap for a maintained
  /// `payments_stats` doc updated by a cloud function or transaction.
  Future<PaymentStats> computeStats() async {
    try {
      final snap = await _firestore.collection('payments').get();
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month);

      double lifetime = 0;
      double thisMonth = 0;
      int pending = 0, confirmed = 0, failed = 0, refunded = 0;
      final perCourse = <String, double>{};

      for (final doc in snap.docs) {
        try {
          final data = doc.data();
          data['paymentID'] = doc.id;
          final p = PaymentRecord.fromMap(data);
          switch (p.status) {
            case PaymentRecordStatus.success:
              confirmed++;
              lifetime += p.amount;
              if (!p.paidAt.isBefore(startOfMonth)) thisMonth += p.amount;
              perCourse[p.courseID] = (perCourse[p.courseID] ?? 0) + p.amount;
            case PaymentRecordStatus.pending:
              pending++;
            case PaymentRecordStatus.failed:
              failed++;
            case PaymentRecordStatus.refunded:
              refunded++;
          }
        } catch (_) {
          // Malformed doc — skip.
        }
      }

      String? topCourseTitle;
      double topRevenue = 0;
      if (perCourse.isNotEmpty) {
        final top = perCourse.entries.reduce(
          (a, b) => a.value >= b.value ? a : b,
        );
        // Hydrate the top course's title rather than ship a raw ID.
        final titles = await _fetchCourseTitles([top.key]);
        topCourseTitle = titles[top.key] ?? top.key;
        topRevenue = top.value;
      }

      return PaymentStats(
        totalRevenueLifetime: lifetime,
        totalRevenueThisMonth: thisMonth,
        pendingCount: pending,
        confirmedCount: confirmed,
        failedCount: failed,
        refundedCount: refunded,
        topCourseTitle: topCourseTitle,
        topCourseRevenue: topRevenue,
      );
    } catch (_) {
      return const PaymentStats(
        totalRevenueLifetime: 0,
        totalRevenueThisMonth: 0,
        pendingCount: 0,
        confirmedCount: 0,
        failedCount: 0,
        refundedCount: 0,
      );
    }
  }

  // ─── Internal lookups ───────────────────────────────────────────────────

  /// Batched `whereIn` over the `users` collection. Missing IDs are silently
  /// dropped — the call site handles "not in map" with a fallback label.
  Future<Map<String, String>> _fetchUserNames(List<String> userIds) async {
    if (userIds.isEmpty) return const {};
    final out = <String, String>{};
    for (var i = 0; i < userIds.length; i += _kWhereInBatch) {
      final slice = userIds.sublist(
        i,
        (i + _kWhereInBatch).clamp(0, userIds.length),
      );
      try {
        final snap = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: slice)
            .get();
        for (final doc in snap.docs) {
          final name = (doc.data()['userName'] as String?)?.trim();
          if (name != null && name.isNotEmpty) out[doc.id] = name;
        }
      } catch (_) {
        // Skip the batch on error — partial maps are better than no map.
      }
    }
    return out;
  }

  /// Batched `whereIn` over the `courses` collection.
  Future<Map<String, String>> _fetchCourseTitles(List<String> courseIds) async {
    if (courseIds.isEmpty) return const {};
    final out = <String, String>{};
    for (var i = 0; i < courseIds.length; i += _kWhereInBatch) {
      final slice = courseIds.sublist(
        i,
        (i + _kWhereInBatch).clamp(0, courseIds.length),
      );
      try {
        final snap = await _firestore
            .collection('courses')
            .where(FieldPath.documentId, whereIn: slice)
            .get();
        for (final doc in snap.docs) {
          final title = (doc.data()['title'] as String?)?.trim();
          if (title != null && title.isNotEmpty) out[doc.id] = title;
        }
      } catch (_) {}
    }
    return out;
  }
}
