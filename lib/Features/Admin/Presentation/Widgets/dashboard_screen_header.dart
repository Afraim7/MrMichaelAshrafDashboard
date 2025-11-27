import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';

class DashboardScreenHeader extends StatelessWidget {
  final String title;
  final String describtion;

  const DashboardScreenHeader({
    super.key,
    required this.title,
    required this.describtion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceAltDark.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // title
            Text(
              title,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.appWhite,
                height: 2,
              ),
            ),

            //describtion
            Text(
              describtion,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondaryDark,
                height: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
