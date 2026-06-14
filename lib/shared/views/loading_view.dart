import 'package:flutter/material.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_typography.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DashboardHelper.appCircularInd,
            const SizedBox(height: 20),
            Text(
              'جاري التحميل ...',
              style: AppTypography.bodySmall(
                AppColors.neutral700,
              ).copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
