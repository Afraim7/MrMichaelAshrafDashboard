import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_radii.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';

class ProgressBar extends StatelessWidget {
  final double progressValue;
  final double? height;
  final double? width;
  final Color? activeColor;
  final Color? backgroundColor;

  const ProgressBar({
    super.key,
    required this.progressValue,
    this.height,
    this.width,
    this.activeColor,
    this.backgroundColor = AppColors.neutral700,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 77.w,
      child: ClipRRect(
        borderRadius: AppRadii.md,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: progressValue),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: backgroundColor ?? AppColors.neutral700,
              color: activeColor ?? AppColors.royalBlue,
              minHeight: height ?? 4.h,
            );
          },
        ),
      ),
    );
  }
}
