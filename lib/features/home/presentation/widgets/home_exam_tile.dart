import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/core/enums/exam_status.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/dashboard_card.dart';

/// Slim exam tile for the home preview grid.
///
/// Shows just the title, grade, duration, and state badge. Tap → exam
/// manager. Compared to [AdminExamCard] this drops the description, question
/// count, full date range, and the trailing "view results" button — admins
/// can drill into the full card from the exams center for those.
class HomeExamTile extends StatelessWidget {
  final Exam exam;
  const HomeExamTile({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();
    final state = exam.state ?? exam.computeUserExamState();
    final accent = state.getStateColor;
    final questionsCount = exam.questions?.length ?? 0;
    final dateRange = exam.examDateRange(exam.startTime, exam.endTime);

    return DashboardCard(
      shadowColor: accent,
      onTap: () => DashboardHelper.showExamsManager(
        context: context,
        existingExam: exam,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header row: glyph + title/grade-duration + state badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withAlpha(28),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    FontAwesomeIcons.fileLines,
                    color: accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        exam.title,
                        style: shahr.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.appWhite,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [
                          exam.grade,
                          if (exam.duration != null) '${exam.duration}د',
                        ].join('  ·  '),
                        style: amiri.copyWith(
                          fontSize: 14,
                          color: AppColors.neutral500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // State badge — the at-a-glance signal for the preview
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withAlpha(28),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withAlpha(60)),
                  ),
                  child: Text(
                    state.label,
                    style: amiri.copyWith(
                      fontSize: 11,
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // ── Footer: question count + date range
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 16,
                  color: AppColors.neutral500,
                ),
                const SizedBox(width: 5),
                Text(
                  '$questionsCount سؤال',
                  style: amiri.copyWith(
                    fontSize: 14,
                    color: AppColors.neutral500,
                  ),
                ),
                const Spacer(),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: AppColors.neutral500,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    dateRange,
                    style: amiri.copyWith(
                      fontSize: 14,
                      color: AppColors.neutral500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
