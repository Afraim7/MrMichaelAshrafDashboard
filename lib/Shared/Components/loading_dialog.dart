import 'package:flutter/material.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/dashboard_helper.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(width: 0.5, color: AppColors.neutral900),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900,
                spreadRadius: 1,
                blurRadius: 2,
              ),
            ],
          ),
          child: Center(child: DashboardHelper.appCircularInd),
        ),
      ),
    );
  }
}
