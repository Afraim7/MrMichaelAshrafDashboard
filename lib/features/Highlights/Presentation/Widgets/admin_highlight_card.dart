import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/highlights_types.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_badge.dart';
import 'package:mrmichaelashrafdashboard/shared/components/meta_row_badge.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';

class AdminHighlightCard extends StatefulWidget {
  final Highlight highlight;

  const AdminHighlightCard({super.key, required this.highlight});

  @override
  State<AdminHighlightCard> createState() => _AdminHighlightCardState();
}

class _AdminHighlightCardState extends State<AdminHighlightCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _isHighlightActive(
      widget.highlight.startTime,
      widget.highlight.endTime,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgDark,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: AppColors.neutral900, width: 1.2),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color:
                          (isActive ? AppColors.pastelGreen : AppColors.midBlue)
                              .withAlpha(90),
                      blurRadius: 15,
                      spreadRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : [],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // TOP ROW -------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AppBadge(
                        text: widget.highlight.grade.label,
                        badgeColor: AppColors.midBlue,
                      ),
                      const SizedBox(width: 6),
                      AppBadge(
                        text: widget.highlight.type.label,
                        badgeColor: AppColors.skyBlue,
                      ),
                    ],
                  ),

                  IconButton(
                    onPressed: () {
                      DashboardHelper.showHighlightManagerSheet(
                        context: context,
                        existingHighlight: widget.highlight,
                      );
                    },
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.neutral50,
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // MESSAGE -------------------------------------------
              Flexible(
                child: Text(
                  widget.highlight.message,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 20,
                    color: AppColors.appWhite,
                    height: 1.7,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Divider ------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Divider(
                  indent: 20,
                  endIndent: 20,
                  height: 0.7,
                  color: const Color.fromARGB(16, 255, 255, 255),
                ),
              ),

              // DATE ROW -----------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: MetaRowBadge(
                      icon: Icons.calendar_month,
                      data: _formatDateRange(
                        widget.highlight.startTime,
                        widget.highlight.endTime,
                      ),
                      dataColor: Colors.white70,
                    ),
                  ),

                  if (isActive)
                    AppBadge(text: 'نشط', badgeColor: AppColors.pastelGreen),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LOGIC
  String _formatDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) {
      return AppStrings.emptyStates.noDate;
    }

    if (startDate != null && endDate != null) {
      return '${startDate.year}/${startDate.month}/${startDate.day}'
          ' - ${endDate.year}/${endDate.month}/${endDate.day}';
    }

    if (startDate != null) {
      return 'من ${startDate.year}/${startDate.month}/${startDate.day}';
    }
    if (endDate != null) {
      return 'حتى ${endDate.year}/${endDate.month}/${endDate.day}';
    }

    return 'لا يوجد تاريخ';
  }

  bool _isHighlightActive(DateTime? startDate, DateTime? endDate) {
    final now = DateTime.now();
    if (startDate == null && endDate == null) return true;
    if (startDate != null && endDate != null) {
      return now.isAfter(startDate.subtract(const Duration(days: 1))) &&
          now.isBefore(endDate.add(const Duration(days: 1)));
    }
    if (startDate != null) {
      return now.isAfter(startDate.subtract(const Duration(days: 1)));
    }
    if (endDate != null) {
      return now.isBefore(endDate.add(const Duration(days: 1)));
    }
    return true;
  }
}
