import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mrmichaelashrafdashboard/core/enums/button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_typography.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/app_sub_button.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final String animationPath;
  final VoidCallback onRetry;
  final String retryLabel;

  const ErrorView({
    super.key,
    required this.message,
    required this.animationPath,
    required this.onRetry,
    this.retryLabel = 'إعادة المحاولة',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LottieBuilder.asset(
              animationPath,
              height: 200,
              fit: BoxFit.cover,
              animate: true,
              repeat: false,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge(
                  AppColors.textSecondaryDark,
                ).copyWith(fontSize: 20),
              ),
            ),
            const SizedBox(height: 22),
            AppSubButton(
              title: 'اعادة التحميل',
              backgroundColor: AppColors.tomatoRed,
              state: ButtonState.idle,
              onTap: onRetry,
              width: 200,
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
