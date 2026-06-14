import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onViewAll;
  final IconData actionIcon;

  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.actionText,
    this.onViewAll,
    this.actionIcon = FontAwesomeIcons.list,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.appWhite,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          if (onViewAll != null)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onViewAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(actionIcon, size: 12, color: AppColors.skyBlue),
                    const SizedBox(width: 8),
                    Text(
                      actionText,
                      style: GoogleFonts.scheherazadeNew(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.skyBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
