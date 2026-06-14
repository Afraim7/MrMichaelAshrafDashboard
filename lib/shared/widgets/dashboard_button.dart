import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/enums/button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';

class DashboardButton extends StatefulWidget {
  final String title;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final int? counter;
  final ButtonState state;
  final VoidCallback onTap;

  const DashboardButton({
    super.key,
    required this.title,
    required this.backgroundColor,
    this.borderColor = AppColors.appTransperent,
    required this.state,
    this.counter,
    this.titleColor = AppColors.appWhite,
    required this.onTap,
  });

  @override
  State<DashboardButton> createState() => _DashboardButtonState();
}

class _DashboardButtonState extends State<DashboardButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const double r = 20;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.state == ButtonState.idle ? widget.onTap : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _pressed ? 0.95 : 1.0,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 55,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _getColor(),
            borderRadius: BorderRadius.circular(r),
            border: BoxBorder.all(width: 1, color: widget.borderColor),
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
      ),
    );
  }

  Widget _buildChild() {
    switch (widget.state) {
      case ButtonState.idle:
        return Text(
          widget.title,
          key: const ValueKey('idle'),
          style: GoogleFonts.scheherazadeNew(
            color: widget.titleColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        );
      case ButtonState.loading:
        return SizedBox(
          key: const ValueKey('loading'),
          height: 20,
          width: 20,
          child: DashboardHelper.appCircularInd,
        );
      case ButtonState.done:
        return const Icon(
          Icons.check,
          key: ValueKey('done'),
          color: AppColors.appWhite,
          size: 24,
        );
      case ButtonState.error:
        return const Icon(
          Icons.warning_rounded,
          key: ValueKey('error'),
          color: AppColors.tomatoRed,
          size: 24,
        );
    }
  }

  Color _getColor() {
    switch (widget.state) {
      case ButtonState.idle:
        return widget.backgroundColor;
      case ButtonState.loading:
        return AppColors.cardDark.withAlpha(230);

      case ButtonState.done:
        return AppColors.pastelGreen.withAlpha(230);
      case ButtonState.error:
        return AppColors.tomatoRed.withAlpha(230);
    }
  }
}
