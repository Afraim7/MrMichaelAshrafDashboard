import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class AppDefaultScreen extends StatelessWidget {
  final String message;
  final String animationPath;
  const AppDefaultScreen({
    super.key,
    required this.message,
    required this.animationPath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30),
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
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
