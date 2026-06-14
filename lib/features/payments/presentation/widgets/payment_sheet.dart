import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/currency_formatter.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_gateway.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_record_status.dart';
import 'package:mrmichaelashrafdashboard/features/payments/data/models/payment_record.dart';

class PaymentSheet extends StatefulWidget {
  final PaymentRecord payment;
  final String userName;
  final String courseTitle;

  const PaymentSheet({
    super.key,
    required this.payment,
    required this.userName,
    required this.courseTitle,
  });

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  late PaymentRecord payment = widget.payment;

  void _copyTxn() {
    Clipboard.setData(ClipboardData(text: payment.transactionID));
    DashboardHelper.showSuccessBar(
      context,
      message: 'تم نسخ رقم المعاملة إلى الحافظة',
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = payment;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHeader(payment: p),

            _SheetDivider(),

            // ── Amount hero ────────────────────────────────────────────
            _AmountHero(payment: p),

            _SheetDivider(),

            // ── الطالب + الكورس ───────────────────────────────────────
            _SectionLabel(
              icon: Icons.person_outline_rounded,
              label: 'الطالب والكورس',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.person_rounded,
              iconColor: AppColors.midBlue,
              label: 'اسم الطالب',
              value: widget.userName,
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.menu_book_rounded,
              iconColor: AppColors.royalYellow,
              label: 'الكورس',
              value: widget.courseTitle,
            ),

            _SheetDivider(),

            // ── معلومات الدفعة ────────────────────────────────────────
            _SectionLabel(
              icon: Icons.receipt_long_outlined,
              label: 'معلومات الدفعة',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: p.paymentGateway.icon,
              iconColor: p.paymentGateway.color,
              label: 'بوابة الدفع',
              value: p.paymentGateway.label,
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.payment_rounded,
              iconColor: AppColors.skyBlue,
              label: 'طريقة الدفع',
              value: p.paymentMethod.isNotEmpty ? p.paymentMethod : '—',
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.tag_rounded,
              iconColor: AppColors.neutral500,
              label: 'رقم المعاملة',
              value: p.transactionID,
              copyable: true,
              onCopy: _copyTxn,
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.fingerprint_rounded,
              iconColor: AppColors.appNavy,
              label: 'معرّف الدفعة',
              value: p.paymentID,
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.calendar_month_rounded,
              iconColor: AppColors.pastelGreen,
              label: 'تاريخ الدفع',
              value: _fmtDate(p.paidAt),
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.schedule_rounded,
              iconColor: AppColors.neutral600,
              label: 'تاريخ الإنشاء',
              value: _fmtDate(p.createdAt),
            ),
            if (p.enrollmentID != null) ...[
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.check_box_rounded,
                iconColor: AppColors.emeraldGreen,
                label: 'معرّف التسجيل',
                value: p.enrollmentID!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.day)}/${two(t.month)}/${t.year}  ${two(t.hour)}:${two(t.minute)}';
  }
}

class _SheetHeader extends StatelessWidget {
  final PaymentRecord payment;
  const _SheetHeader({required this.payment});

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();
    final accent = payment.status.color;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تفاصيل الدفعة',
                style: shahr.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withAlpha(35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withAlpha(60)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(payment.status.icon, size: 12, color: accent),
                        const SizedBox(width: 5),
                        Text(
                          payment.status.label,
                          style: amiri.copyWith(
                            fontSize: 12,
                            color: accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accent.withAlpha(28),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(Icons.payments_rounded, color: accent, size: 22),
        ),
      ],
    );
  }
}

class _AmountHero extends StatelessWidget {
  final PaymentRecord payment;
  const _AmountHero({required this.payment});

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();
    final accent = payment.status.color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: accent.withAlpha(20),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withAlpha(50), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المبلغ',
            style: amiri.copyWith(fontSize: 13, color: AppColors.neutral500),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.withCode(payment.amount, payment.currency),
            style: shahr.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: accent,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 22),
    child: Divider(height: 1, color: AppColors.neutral900),
  );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: AppColors.neutral500),
      const SizedBox(width: 8),
      Text(
        label,
        style: GoogleFonts.scheherazadeNew(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral300,
        ),
      ),
    ],
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool copyable;
  final VoidCallback? onCopy;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.copyable = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: amiri.copyWith(
                    fontSize: 12,
                    color: AppColors.neutral500,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: shahr.copyWith(
                    fontSize: 15,
                    color: AppColors.textPrimaryDark,
                    height: 1.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (copyable) ...[
            const SizedBox(width: 10),
            IconButton(
              tooltip: 'نسخ',
              onPressed: onCopy,
              icon: const Icon(
                Icons.copy_rounded,
                size: 16,
                color: AppColors.neutral500,
              ),
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}
