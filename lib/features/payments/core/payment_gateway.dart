import 'package:flutter/material.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

/// Source of a payment record. Webhooked gateways (Paymob/Fawry/Stripe/PayPal)
/// arrive already-confirmed; manual ones queue up for admin verification.
enum PaymentGateway { paymob, fawry, stripe, paypal, manual }

extension PaymentGatewayX on PaymentGateway {
  String get label {
    switch (this) {
      case PaymentGateway.paymob:
        return 'Paymob';
      case PaymentGateway.fawry:
        return 'Fawry';
      case PaymentGateway.stripe:
        return 'Stripe';
      case PaymentGateway.paypal:
        return 'PayPal';
      case PaymentGateway.manual:
        return 'manual';
    }
  }

  /// Accent tint used on gateway badges.
  Color get color {
    switch (this) {
      case PaymentGateway.paymob:
        return AppColors.midBlue;
      case PaymentGateway.fawry:
        return AppColors.energyOrange;
      case PaymentGateway.stripe:
        return AppColors.royalBlue;
      case PaymentGateway.paypal:
        return AppColors.skyBlue;
      case PaymentGateway.manual:
        return AppColors.emeraldGreen;
    }
  }

  /// Glyph for the gateway badge. Falls back to a generic card icon for the
  /// ones FontAwesome doesn't ship a brand glyph for in this version.
  IconData get icon {
    switch (this) {
      case PaymentGateway.paymob:
        return Icons.credit_card_rounded;
      case PaymentGateway.fawry:
        return Icons.receipt_long_rounded;
      case PaymentGateway.stripe:
        return Icons.payment;
      case PaymentGateway.paypal:
        return Icons.account_balance_wallet_rounded;
      case PaymentGateway.manual:
        return Icons.payments_rounded;
    }
  }
}
