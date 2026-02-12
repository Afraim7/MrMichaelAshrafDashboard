import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mrmichaelashrafdashboard/core/enums/sub_button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_sub_button.dart';

class AppDialog extends StatelessWidget {
  final String header; // Title text
  final String description; // Description text
  final String lottiePath; // Animation path

  // Buttons customization
  final String? cancelTitle;
  final String? confirmTitle;
  final Color? cancelColor;
  final Color? confirmColor;

  // Button logic
  final VoidCallback onConfirm;
  final SubButtonState? onConfirmState;

  const AppDialog({
    super.key,
    required this.header,
    required this.description,
    required this.lottiePath,
    required this.onConfirm,
    this.onConfirmState,
    this.cancelTitle = 'الغاء',
    this.confirmTitle = 'تأكيد',
    this.cancelColor = AppColors.surfaceDark,
    this.confirmColor = AppColors.posterRed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      elevation: 10,
      insetAnimationCurve: Curves.fastEaseInToSlowEaseOut,
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: DashboardHelper.screenHeight * 0.7,
          minWidth: 250,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(35),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ──────────────── Lottie Icon ────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Lottie.asset(
                lottiePath,
                width: 77,
                height: 77,
                repeat: false,
              ),
            ),

            // ──────────────── Header ────────────────
            Text(
              header,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.appWhite,
                height: 2,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // ──────────────── Description ────────────────
            Text(
              description,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: AppColors.neutral500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: AppSubButton(
                    title: cancelTitle ?? 'إلغاء',
                    state: SubButtonState.idle,
                    backgroundColor: cancelColor ?? AppColors.surfaceDark,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),

                const SizedBox(width: 8),

                // Confirm Button
                Expanded(
                  child: AppSubButton(
                    title: confirmTitle ?? 'تأكيد',
                    backgroundColor: confirmColor ?? AppColors.posterRed,
                    state: onConfirmState ?? SubButtonState.idle,
                    onTap: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
