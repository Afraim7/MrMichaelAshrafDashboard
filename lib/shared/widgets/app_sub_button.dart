import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrmichaelashrafdashboard/core/enums/button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_typography.dart';
import 'package:mrmichaelashrafdashboard/shared/animations/pressing_effect.dart';

class AppSubButton extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final double height;
  final double borderRadius;
  final double width;
  final double titleSize;
  final ButtonState state;
  final VoidCallback onTap;

  const AppSubButton({
    super.key,
    required this.title,
    required this.backgroundColor,
    this.borderColor = AppColors.appTransperent,
    required this.state,
    this.titleColor = AppColors.appWhite,
    required this.onTap,
    this.height = 55,
    this.borderRadius = 15,
    this.width = double.infinity,
    this.titleSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final double r = borderRadius;

    return PressingEffect(
      enable: state == ButtonState.idle,
      onTap: state == ButtonState.idle
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      scale: 0.95,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: _getColor(),
          borderRadius: BorderRadius.circular(r),
          border: BoxBorder.all(width: 1, color: borderColor),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: _buildChild(),
          ),
        ),
      ),
    );
  }

  Widget _buildChild() {
    switch (state) {
      case ButtonState.idle:
        return Text(
          title,
          key: const ValueKey("idle"),
          style: AppTypography.buttonText(
            AppColors.appWhite,
          ).copyWith(fontSize: titleSize, color: titleColor),
        );

      case ButtonState.loading:
        return SizedBox(
          key: const ValueKey("loading"),
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.pastelYellow),
          ),
        );

      case ButtonState.done:
        return const Icon(
          Icons.check,
          key: ValueKey("done"),
          color: AppColors.appWhite,
          size: 24,
        );

      case ButtonState.error:
        return const Icon(
          Icons.warning_rounded,
          key: ValueKey("error"),
          color: AppColors.tomatoRed,
          size: 24,
        );
    }
  }

  Color _getColor() {
    switch (state) {
      case ButtonState.idle:
        return backgroundColor;
      case ButtonState.loading:
        return AppColors.cardDark;
      case ButtonState.done:
        return AppColors.pastelGreen;
      case ButtonState.error:
        return AppColors.tomatoRed;
    }
  }
}
