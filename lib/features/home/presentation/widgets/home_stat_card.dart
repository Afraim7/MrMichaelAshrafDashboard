import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class HomeStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accent;

  const HomeStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.accent = AppColors.midBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltDark.withAlpha(85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withAlpha(40)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withAlpha(28),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: accent),
          ),

          const SizedBox(height: 14),

          // Value first (bigger, accent-colored) — that's the "what" the
          // admin's eye is meant to land on; the title sits underneath as
          // context.
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.appWhite,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.scheherazadeNew(
              color: AppColors.neutral500,
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
