import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class SheetSubSectionLabel extends StatelessWidget {
  final String label;
  const SheetSubSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 3,
        height: 16,
        decoration: BoxDecoration(
          color: AppColors.midBlue,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        label,
        style: GoogleFonts.scheherazadeNew(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral300,
        ),
      ),
    ],
  );
}
