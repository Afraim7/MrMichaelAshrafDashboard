import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class AdminHoverButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const AdminHoverButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColors.surfaceDark.withAlpha(204),
            border: Border.all(color: AppColors.appNavy, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.skyBlue),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 16,
                  color: AppColors.skyBlue,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
