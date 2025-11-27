import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_radii.dart';

class AppButton extends StatefulWidget {
  final String buttonTitle;
  final VoidCallback onTap;
  final Color foregroundColor;
  final Color backgroundColor;

  const AppButton({
    super.key,
    required this.buttonTitle,
    required this.onTap,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final BorderRadius r = AppRadii.xl;
    final double shift = 6.r;
    final double downShift = 4.r;

    final backShift = _pressed ? downShift : shift;
    final frontShift = _pressed ? Offset(downShift, downShift) : Offset.zero;

    return SizedBox(
      height: 55.h,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Back layer (with clip to avoid bleed)
          Positioned.fill(
            child: TweenAnimationBuilder<Offset>(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              tween: Tween<Offset>(
                begin: Offset(shift, shift),
                end: Offset(backShift, backShift),
              ),
              builder: (_, offset, child) =>
                  Transform.translate(offset: offset, child: child),
              child: ClipRRect(
                borderRadius: r,
                child: Container(color: widget.backgroundColor),
              ),
            ),
          ),

          // Front button
          Positioned.fill(
            child: TweenAnimationBuilder<Offset>(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              tween: Tween<Offset>(begin: Offset.zero, end: frontShift),
              builder: (_, offset, child) =>
                  Transform.translate(offset: offset, child: child),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 120),
                scale: _pressed ? 0.99 : 1.015,
                child: Material(
                  color: widget.foregroundColor,
                  borderRadius: r,
                  child: InkWell(
                    borderRadius: r,
                    onHighlightChanged: (isDown) {
                      setState(() => _pressed = isDown);
                    },
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onTap();
                    },
                    child: Center(
                      child: Text(
                        widget.buttonTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.scheherazadeNew(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
