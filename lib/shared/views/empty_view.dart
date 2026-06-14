import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_typography.dart';

/// Empty-state placeholder for centers and lists with no data to show.
///
/// Pairs a Lottie illustration with a short message — caller supplies both
/// so each surface keeps its own visual identity (no-courses, no-students,
/// no-payments, …). For errors with a retry affordance, use [ErrorView]
/// instead — this view stays intentionally action-less so empty data and
/// failed loads never get visually confused.
class EmptyView extends StatelessWidget {
  final String message;
  final String animationPath;

  const EmptyView({
    super.key,
    required this.message,
    required this.animationPath,
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
              height: 300,
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
          ],
        ),
      ),
    );
  }
}
