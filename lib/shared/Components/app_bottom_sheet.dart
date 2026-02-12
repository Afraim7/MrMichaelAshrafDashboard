import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_radii.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';

class AppBottomSheet {
  final Widget child;
  AppBottomSheet({required this.child});

  Future<void> showBottomSheet(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.appTransperent,
      elevation: 0,
      isScrollControlled: true,
      isDismissible: true,
      showDragHandle: true,
      enableDrag: true,
      builder: (context) {
        return Container(
          width: DashboardHelper.screenWidth,
          padding: EdgeInsets.only(top: 50, bottom: 0, left: 20, right: 20),
          constraints: BoxConstraints(
            minHeight: DashboardHelper.screenHeight * 0.4,
            maxHeight: DashboardHelper.screenHeight * 0.85,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: AppRadii.elliptical(
              topLeftX: 50.r,
              topLeftY: 35.r,
              topRightX: 50.r,
              topRightY: 35.r,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
