import 'package:mrmichaelashrafdashboard/features/payments/core/payment_gateway.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_method.dart';
import 'package:mrmichaelashrafdashboard/features/payments/logic/entities/billing_data.dart';

class PaymentRequest {
  final String referenceId;
  final int amount;
  final String currency;
  final String description;
  final BillingData? billingData;
  final PaymentMethod method;
  final PaymentGateway gateway;

  PaymentRequest({
    required this.referenceId,
    required this.amount,
    required this.currency,
    required this.description,
    this.billingData,
    required this.method,
    required this.gateway,
  });
}
