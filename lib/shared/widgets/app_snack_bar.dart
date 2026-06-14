import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class AppSnackBar {
  final String message;
  final String? icon;
  final Color backgroundColor;
  final Duration duration;
  final double maxWidth;

  AppSnackBar({
    required this.message,
    this.icon,
    required this.backgroundColor,
    this.duration = const Duration(seconds: 3),
    this.maxWidth = 600,
  });

  void showSnackBar(BuildContext context) => Flushbar(
    maxWidth: maxWidth,
    messageText: Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox.square(
                dimension: 60,
                child: Center(
                  child: Lottie.asset(
                    icon!,
                    fit: BoxFit.contain,
                    delegates: LottieDelegates(text: (key) => 'تنبيه'),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.start,
                  softWrap: true,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: AppColors.appWhite,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    isDismissible: true,
    flushbarPosition: FlushbarPosition.TOP,
    backgroundColor: backgroundColor,
    borderRadius: BorderRadius.circular(25),
    margin: EdgeInsets.all(16),
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    borderColor: AppColors.neutral900,
    borderWidth: 0.5,
    boxShadows: const [
      BoxShadow(blurRadius: 10, spreadRadius: 1, color: Colors.black26),
    ],
    duration: duration,
    forwardAnimationCurve: Curves.linearToEaseOut,
    reverseAnimationCurve: Curves.linearToEaseOut,
  )..show(context);
}
