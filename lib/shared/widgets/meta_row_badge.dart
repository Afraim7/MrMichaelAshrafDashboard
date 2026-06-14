import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

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
          const SizedBox(width: 12),
          // Plain Text (was SelectableText) — the selection container reported
          // unstable intrinsic sizes inside `Row > Flexible`, and its built-in
          // gestures collided with the outer DashboardCard's MouseRegion +
          // GestureDetector. That combination tripped both "RenderBox was not
          // laid out" and "Cannot hit test a render box with no size" assertions
          // in the exams center. Cards are click-to-open; selection wasn't
          // meaningful here anyway.
          Flexible(
            child: Text(
              data!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
