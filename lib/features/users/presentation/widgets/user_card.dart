import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course_enrollment.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam_result.dart';
import 'package:mrmichaelashrafdashboard/features/users/data/models/app_user.dart';
import 'package:mrmichaelashrafdashboard/features/users/presentation/widgets/user_sheet.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/dashboard_card.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/meta_row_badge.dart';

// ─────────────────────────────────────────────────────────────────────────────
// User card (grid / list tile)
// ─────────────────────────────────────────────────────────────────────────────

class UserCard extends StatelessWidget {
  final AppUser student;
  final List<Course> enrolledCourses;
  final List<CourseEnrollment> enrollments;
  final List<Exam> takenExams;
  final List<ExamResult> examResults;

  const UserCard({
    super.key,
    required this.student,
    this.enrolledCourses = const [],
    this.enrollments = const [],
    this.takenExams = const [],
    this.examResults = const [],
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      onTap: () => _showUserAdminSheet(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardAvatar(student: student),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.userName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 2,
                    ),
                  ),
                  Text(
                    student.grade.label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.white54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 25),
                  MetaRowBadge(icon: Icons.email_outlined, data: student.email),
                  MetaRowBadge(
                    icon: Icons.phone_android_rounded,
                    data: student.phone,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the [UserSheet] from `student_sheet.dart` as a modal bottom sheet
  /// — the sheet itself owns all the section/tile UI.
  void _showUserAdminSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: UserSheet(
          student: student,
          enrolledCourses: enrolledCourses,
          enrollments: enrollments,
          takenExams: takenExams,
          examResults: examResults,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small avatar dedicated to the card — mirrors the bigger one used in the sheet
// but stays self-contained to avoid cross-file coupling.
// ─────────────────────────────────────────────────────────────────────────────

class _CardAvatar extends StatelessWidget {
  final AppUser student;
  const _CardAvatar({required this.student});

  @override
  Widget build(BuildContext context) {
    final iconPath = student.setProfileIcon;
    final initial = student.userName.trim().isNotEmpty
        ? student.userName.trim()[0]
        : '؟';

    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.appNavy,
        shape: BoxShape.circle,
      ),
      child: iconPath.isNotEmpty
          ? ClipOval(child: Image.asset(iconPath, fit: BoxFit.cover))
          : Center(
              child: Text(
                initial,
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.royalYellow,
                ),
              ),
            ),
    );
  }
}
