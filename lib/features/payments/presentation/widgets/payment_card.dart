import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/currency_formatter.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_gateway.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_record_status.dart';
import 'package:mrmichaelashrafdashboard/features/payments/data/models/payment_record.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/dashboard_card.dart';

class PaymentCard extends StatelessWidget {
  final PaymentRecord payment;
  final String userName;
  final String courseTitle;
  final VoidCallback? onTap;

  const PaymentCard({
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
    final statusColor = payment.status.color;

    return DashboardCard(
      onTap: onTap,
      shadowColor: statusColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top row: status + gateway badges ────────────────────────
            Row(
              children: [
                _PaymentBadge(
                  text: payment.status.label,
                  color: statusColor,
                  icon: payment.status.icon,
                ),
                const SizedBox(width: 6),
                _PaymentBadge(
                  text: payment.paymentGateway.label,
                  color: payment.paymentGateway.color,
                  icon: payment.paymentGateway.icon,
                  outlined: true,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── User name ────────────────────────────────────────────
            Row(
              children: [
                _Avatar(name: userName, accent: statusColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: shahr.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.appWhite,
                          height: 1.4,
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
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ── Amount (the main reason this card exists) ───────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withAlpha(45), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المبلغ المدفوع',
                    style: amiri.copyWith(
                      fontSize: 11,
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.withCode(
                      payment.amount,
                      payment.currency,
                    ),
                    style: shahr.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Footer row: date + truncated transaction id ─────────────
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: AppColors.neutral600,
                ),
                const SizedBox(width: 5),
                Text(
                  _formatDate(payment.paidAt),
                  style: amiri.copyWith(
                    fontSize: 14,
                    color: AppColors.neutral500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.tag_rounded, size: 14, color: AppColors.neutral600),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _shortTxn(payment.transactionID),
                    style: amiri.copyWith(
                      fontSize: 14,
                      color: AppColors.neutral500,
                      letterSpacing: 0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Short date like `15/3 14:22` — keeps the footer compact and gives the
  /// admin time-of-day context without a full year/month name.
  String _formatDate(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.day)}/${two(t.month)}  ${two(t.hour)}:${two(t.minute)}';
  }

  /// Show only the tail of long transaction IDs (gateway prefixes are noisy).
  String _shortTxn(String id) {
    if (id.length <= 12) return id;
    return '...${id.substring(id.length - 10)}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal building blocks
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final bool outlined;

  const _PaymentBadge({
    required this.text,
    required this.color,
    required this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: outlined ? color.withAlpha(14) : color.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withAlpha(outlined ? 80 : 60),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.amiri(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small avatar that shows the student's first letter. Color matches the
/// payment's status so confirmed payments feel "green" end to end.
class _Avatar extends StatelessWidget {
  final String name;
  final Color accent;
  const _Avatar({required this.name, required this.accent});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0] : '؟';
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: accent.withAlpha(35),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.scheherazadeNew(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: accent,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
