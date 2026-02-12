import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/enums/exam_status.dart';
import 'package:mrmichaelashrafdashboard/core/enums/sub_button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_badge.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_sub_button.dart';
import 'package:mrmichaelashrafdashboard/shared/components/meta_row_badge.dart';

class AdminExamCard extends StatefulWidget {
  final String examTitle;
  final String examDescribtion;
  final String grade;
  final ExamStatus examState;
  final int? duration;
  final int? questionsCount;
  final int? examFullMark;
  final String? examDateRange;
  final bool? isExamActive;
  final VoidCallback? onViewResults;
  final VoidCallback? onViewExamManager;

  const AdminExamCard({
    super.key,
    required this.examTitle,
    required this.examDescribtion,
    required this.grade,
    required this.examState,
    this.isExamActive,
    this.duration,
    this.questionsCount,
    this.examFullMark,
    this.examDateRange,
    this.onViewResults,
    this.onViewExamManager,
  });

  @override
  State<AdminExamCard> createState() => _AdminExamCardState();
}

class _AdminExamCardState extends State<AdminExamCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 160),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgDark,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: AppColors.neutral900, width: 1.2),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: (widget.examState.getStateColor).withAlpha(90),
                      blurRadius: 15,
                      spreadRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : [],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STATUS + MENU
              Row(
                children: [
                  AppBadge(
                    text: widget.examState.label,
                    badgeColor: widget.examState.getStateColor,
                  ),
                  const SizedBox(width: 10),
                  AppBadge(text: widget.grade, badgeColor: AppColors.skyBlue),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onViewExamManager,
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.neutral50,
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // TITLE
              Text(
                widget.examTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 2,
                ),
              ),

              // DESCRIPTION
              Text(
                widget.examDescribtion,
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 14,
                  height: 1.7,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 25),

              // Details
              if (widget.examDateRange!.isNotEmpty)
                MetaRowBadge(
                  icon: Icons.calendar_month,
                  label: widget.examDateRange,
                ),
              if (widget.questionsCount != null)
                MetaRowBadge(
                  icon: Icons.filter_none_sharp,
                  label: '${widget.questionsCount} سؤال',
                ),
              if (widget.duration != null)
                MetaRowBadge(
                  icon: Icons.timer,
                  label: '${widget.duration} دقيقه',
                ),
              if (widget.examFullMark != null)
                MetaRowBadge(
                  icon: Icons.sports_score_rounded,
                  label: '${widget.examFullMark} درجة',
                ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Divider(
                  indent: 20,
                  endIndent: 20,
                  height: 0.7,
                  color: const Color.fromARGB(16, 255, 255, 255),
                ),
              ),

              // FOOTER BUTTON
              AppSubButton(
                title: 'عرض النتائج',
                backgroundColor: AppColors.surfaceDark,
                titleColor: AppColors.appWhite,
                onTap: widget.onViewResults!,
                state: SubButtonState.idle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
