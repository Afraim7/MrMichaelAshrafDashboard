import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_gaps.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/sub_button_state.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/app_sub_button.dart';

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
          maxHeight: AppHelper.screenHeight * 0.7,
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
            AppGaps.v5,

            // ──────────────── Lottie Icon ────────────────
            Lottie.asset(lottiePath, width: 60, height: 60, repeat: false),

            AppGaps.v5,

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

            AppGaps.v2,

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

            AppGaps.v8,

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
