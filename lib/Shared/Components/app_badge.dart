import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final Color badgeColor;

  const AppBadge({
    super.key,
    required this.text,
    this.badgeColor = AppColors.appNavy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(51),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: GoogleFonts.scheherazadeNew(
          fontSize: 15,
          color: badgeColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
