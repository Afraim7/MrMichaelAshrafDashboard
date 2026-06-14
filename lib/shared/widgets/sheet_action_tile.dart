import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class SheetActionTile extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDanger;
  final bool loading;

  const SheetActionTile({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isDanger
                ? AppColors.tomatoRed.withAlpha(12)
                : AppColors.surfaceAltDark,
            borderRadius: BorderRadius.circular(16),
            border: isDanger
                ? Border.all(color: AppColors.tomatoRed.withAlpha(40), width: 1)
                : null,
          ),
          child: Row(
            children: [
              // Icon tile
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(28),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 14),

              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: shahr.copyWith(
                        fontSize: 16,
                        color: isDanger
                            ? AppColors.tomatoRed
                            : AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: amiri.copyWith(
                        fontSize: 12,
                        color: AppColors.neutral500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing affordance — spinner during action, chevron otherwise.
              if (loading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      accentColor.withAlpha(200),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDanger
                      ? AppColors.tomatoRed.withAlpha(140)
                      : AppColors.neutral600,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
