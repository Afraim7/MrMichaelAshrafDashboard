import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/sub_button_state.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/dashboard_helper.dart';

class AppSubButton extends StatefulWidget {
  final String title;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final int? counter;
  final SubButtonState state;
  final VoidCallback onTap;

  const AppSubButton({
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
  State<AppSubButton> createState() => _AppSubButtonState();
}

class _AppSubButtonState extends State<AppSubButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double r = 20;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
      },
      onTapCancel: () {
        setState(() => _pressed = false);
      },
      onTap: widget.state == SubButtonState.idle ? widget.onTap : null,
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
      case SubButtonState.idle:
        return Text(
          widget.title,
          key: const ValueKey("idle"),
          style: GoogleFonts.scheherazadeNew(
            color: widget.titleColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        );
      case SubButtonState.loading:
        return SizedBox(
          key: ValueKey("loading"),
          height: 20,
          width: 20,
          child: AppHelper.appCircularInd,
        );
      case SubButtonState.done:
        return Icon(
          Icons.check,
          key: ValueKey("done"),
          color: AppColors.appWhite,
          size: 24,
        );
      case SubButtonState.error:
        return const Icon(
          Icons.warning_rounded,
          key: ValueKey("error"),
          color: AppColors.tomatoRed,
          size: 24,
        );
      case SubButtonState.countingDown:
        return Text(
          widget.counter != null ? '${widget.counter}' : '',
          key: ValueKey("countingDown"),
          style: TextStyle(
            color: AppColors.appWhite,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        );
    }
  }

  Color _getColor() {
    switch (widget.state) {
      case SubButtonState.idle:
        return widget.backgroundColor;
      case SubButtonState.loading:
        return AppColors.cardDark.withOpacity(0.9);
      case SubButtonState.countingDown:
        return AppColors.cardDark.withOpacity(0.9);
      case SubButtonState.done:
        return AppColors.pastelGreen.withOpacity(0.9);
      case SubButtonState.error:
        return AppColors.tomatoRed.withOpacity(0.9);
    }
  }
}
