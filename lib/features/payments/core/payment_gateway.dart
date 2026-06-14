import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        return FontAwesomeIcons.creditCard;
      case PaymentGateway.fawry:
        return FontAwesomeIcons.receipt;
      case PaymentGateway.stripe:
        return FontAwesomeIcons.stripeS;
      case PaymentGateway.paypal:
        return FontAwesomeIcons.paypal;
      case PaymentGateway.manual:
        return FontAwesomeIcons.moneyBill;
    }
  }
}
