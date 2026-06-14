import 'package:flutter/material.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

/// Persisted state of a payment record in the `payments` collection.
/// Reflects the lifecycle of a charge after the gateway result has settled.
enum PaymentRecordStatus { pending, success, failed, refunded }

/// UI-facing helpers — kept as an extension so the enum itself stays a
/// plain data-only declaration and can be safely persisted by `name`.
extension PaymentRecordStatusX on PaymentRecordStatus {
  /// Arabic label shown on cards, badges, and section headers.
  String get label {
    switch (this) {
      case PaymentRecordStatus.pending:
        return 'بانتظار التأكيد';
      case PaymentRecordStatus.success:
        return 'مؤكدة';
      case PaymentRecordStatus.failed:
        return 'مرفوضة';
      case PaymentRecordStatus.refunded:
        return 'مستردة';
    }
  }

  /// Accent color used for badges, borders, and tinted tile backgrounds.
  /// Mirrors the pattern used by [ExamStatusX.getStateColor] so the visual
  /// language stays consistent across centers.
  Color get color {
    switch (this) {
      case PaymentRecordStatus.pending:
        return AppColors.royalYellow;
      case PaymentRecordStatus.success:
        return AppColors.pastelGreen;
      case PaymentRecordStatus.failed:
        return AppColors.tomatoRed;
      case PaymentRecordStatus.refunded:
        return AppColors.skyBlue;
    }
  }

  /// Glyph paired with the badge — fast scanability in dense lists.
  IconData get icon {
    switch (this) {
      case PaymentRecordStatus.pending:
        return Icons.hourglass_top_rounded;
      case PaymentRecordStatus.success:
        return Icons.check_circle_rounded;
      case PaymentRecordStatus.failed:
        return Icons.cancel_rounded;
      case PaymentRecordStatus.refunded:
        return Icons.replay_rounded;
    }
  }
}
