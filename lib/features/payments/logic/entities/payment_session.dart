import 'package:mrmichaelashrafdashboard/features/payments/core/payment_gateway.dart';

class PaymentSession {
  final String sessionToken;
  final PaymentGateway gateway;
  final DateTime expiresAt;
  final Map<String, String>? metadata;

  PaymentSession({
    required this.sessionToken,
    required this.gateway,
    required this.expiresAt,
    this.metadata,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
