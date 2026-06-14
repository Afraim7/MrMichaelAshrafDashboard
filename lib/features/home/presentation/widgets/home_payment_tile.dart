import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/currency_formatter.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_gateway.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_record_status.dart';
import 'package:mrmichaelashrafdashboard/features/payments/data/models/payment_record.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/dashboard_card.dart';

/// Slim payment tile for the home "بانتظار التأكيد" preview.
///
/// Optimized for the pending-verification queue: student name, course title,
/// amount, status badge. Tap fires the parent's callback so the home screen
/// can open the full payment sheet with the cubit forwarded.
class HomePaymentTile extends StatelessWidget {
  final PaymentRecord payment;
  final String userName;
  final String courseTitle;
  final VoidCallback? onTap;

  const HomePaymentTile({
    super.key,
    required this.payment,
    required this.userName,
    required this.courseTitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();
    final accent = payment.status.color;

    final gateway = payment.paymentGateway;

    return DashboardCard(
      shadowColor: accent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header row: glyph + name/course + amount chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withAlpha(28),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(payment.status.icon, color: accent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        style: shahr.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.appWhite,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        courseTitle,
                        style: amiri.copyWith(
                          fontSize: 14,
                          color: AppColors.neutral500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Amount chip — the headline value for a payment row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withAlpha(35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    CurrencyFormatter.withCode(
                      payment.amount,
                      payment.currency,
                    ),
                    style: amiri.copyWith(
                      fontSize: 14,
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // ── Footer: gateway badge + paid-at timestamp
            const SizedBox(height: 16),
            Row(
              children: [
                // Gateway badge (Paymob / Fawry / Stripe / PayPal / Manual)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: gateway.color.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: gateway.color.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(gateway.icon, size: 12, color: gateway.color),
                      const SizedBox(width: 5),
                      Text(
                        gateway.label,
                        style: amiri.copyWith(
                          fontSize: 12,
                          color: gateway.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: AppColors.neutral500,
                ),
                const SizedBox(width: 5),
                Text(
                  _formatDate(payment.paidAt),
                  style: amiri.copyWith(
                    fontSize: 12,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Compact `dd/MM HH:mm` for the footer — matches the format used in the
  /// full [AdminPaymentCard] so admins see consistent dates across surfaces.
  String _formatDate(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.day)}/${two(t.month)}  ${two(t.hour)}:${two(t.minute)}';
  }
}
