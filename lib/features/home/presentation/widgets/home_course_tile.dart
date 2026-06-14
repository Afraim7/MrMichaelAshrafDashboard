import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/currency_formatter.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/dashboard_card.dart';

/// Slim course tile for the home preview grid.
///
/// Same `DashboardCard` chrome as the full `AdminCourseCard`, but with a much
/// tighter information density — title, grade, lesson count, price chip. No
/// thumbnail (saves a network round-trip), no description, no enrollment
/// stats. Tap routes through to the manager sheet for the full view.
class HomeCourseTile extends StatelessWidget {
  final Course course;
  const HomeCourseTile({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();

    final hasDescription = course.description.trim().isNotEmpty;

    return DashboardCard(
      onTap: () => DashboardHelper.showCoursesManager(
        context: context,
        existingCourse: course,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header row: glyph + title/grade-lessons + price chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.midBlue.withAlpha(28),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.midBlue,
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
                        course.title,
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
                        '${course.grade.label}  ·  ${course.lessons.length} درس',
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
                // Price chip — the headline number for the preview
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldGreen.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    CurrencyFormatter.compact(course.price),
                    style: amiri.copyWith(
                      fontSize: 12,
                      color: AppColors.emeraldGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // ── Description — only shown when the course has one. 2 lines
            // max keeps the tile from running tall on long write-ups.
            if (hasDescription) ...[
              const SizedBox(height: 12),
              Text(
                course.description,
                style: amiri.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondaryDark,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // ── Footer: enrollment count chip on the right
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.people_alt_outlined,
                  size: 16,
                  color: AppColors.neutral500,
                ),
                const SizedBox(width: 6),
                Text(
                  '${course.enrollmentCount} طالب مسجل',
                  style: amiri.copyWith(
                    fontSize: 14,
                    color: AppColors.neutral500,
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
