import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class SheetSectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const SheetSectionHeader({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: AppColors.neutral500),
      const SizedBox(width: 8),
      Text(
        label,
        style: GoogleFonts.scheherazadeNew(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral300,
        ),
      ),
    ],
  );
}
