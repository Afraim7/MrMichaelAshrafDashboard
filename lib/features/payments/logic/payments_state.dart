import 'package:equatable/equatable.dart';
import 'package:mrmichaelashrafdashboard/features/payments/data/models/payment_record.dart';

sealed class PaymentsState extends Equatable {
  const PaymentsState();

  @override
  List<Object?> get props => [];
}

final class PaymentsInitial extends PaymentsState {
  const PaymentsInitial();
}

// ─── fetchPaymentsPage ──────────────────────────────────────────────────
final class FetchPaymentsLoading extends PaymentsState {
  const FetchPaymentsLoading();
}

final class FetchPaymentsSuccess extends PaymentsState {
  final List<PaymentRecord> payments;
  final int page;
  final int pageSize;
  final int totalCount;

  /// userID → display name. Pre-resolved by the cubit so the center never
  /// has to know about the `users` collection. Missing keys (deleted users
  /// etc.) fall back to "طالب غير معروف" at the call site.
  final Map<String, String> userNamesMap;

  /// courseID → course title. Same hydration pattern as [userNamesMap].
  final Map<String, String> courseTitlesMap;

  const FetchPaymentsSuccess({
    required this.payments,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.userNamesMap,
    required this.courseTitlesMap,
  });
  @override
  List<Object?> get props => [
        payments,
        page,
        pageSize,
        totalCount,
        userNamesMap,
        courseTitlesMap,
      ];
}

final class FetchPaymentsError extends PaymentsState {
  final String message;
  const FetchPaymentsError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
extension PaymentsStateX on PaymentsState {
  String? get errorMessage => switch (this) {
    FetchPaymentsError(:final message) => message,
    _ => null,
  };

  bool get isLoading => this is FetchPaymentsLoading;
}
