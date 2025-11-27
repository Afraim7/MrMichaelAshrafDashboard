import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';

class MetaRowBadge extends StatelessWidget {
  final IconData icon;
  final String? label;
  final String? data;
  final Color iconColor;
  final double iconSize;
  final Color? labelColor;
  final double labelSize;
  final double dataSize;
  final Color dataColor;

  const MetaRowBadge({
    super.key,
    required this.icon,
    this.label = '',
    this.data = '',
    this.iconSize = 17,
    this.iconColor = AppColors.neutral600,
    this.labelSize = 17,
    this.labelColor = AppColors.neutral600,
    this.dataSize = 17,
    this.dataColor = AppColors.appWhite,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: iconSize, color: iconColor),

        if (label != null && label!.isNotEmpty) ...[
          const SizedBox(width: 7),
          Text(
            label!,
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: GoogleFonts.scheherazadeNew(
              textStyle: TextStyle(
                color: labelColor,
                fontSize: labelSize,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],

        if (data != null && data!.isNotEmpty) ...[
          SizedBox(width: 12),
          Flexible(
            child: SelectableText(
              data!,
              selectionColor: AppColors.skyBlue.withOpacity(0.5),
              style: GoogleFonts.scheherazadeNew(
                textStyle: TextStyle(
                  color: dataColor,
                  fontSize: dataSize,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
