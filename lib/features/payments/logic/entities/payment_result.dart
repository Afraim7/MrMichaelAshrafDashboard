import 'package:mrmichaelashrafdashboard/features/payments/core/payment_status.dart';

class PaymentResult {
  final String transactionId;
  final PaymentStatus status;
  final String message;
  final String? redirectUrl;

  PaymentResult({
    required this.transactionId,
    required this.status,
    this.message = '',
    this.redirectUrl,
  });

  bool get isSuccess => status == PaymentStatus.success;
  bool get isPending => status == PaymentStatus.pending;
  bool get isCancelled => status == PaymentStatus.cancelled;
  bool get isFailure => status == PaymentStatus.failure;
}
