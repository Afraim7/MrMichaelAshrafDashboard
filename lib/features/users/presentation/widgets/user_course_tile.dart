import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/enums/enrollment_status.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/subject.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course_enrollment.dart';

class UserCourseTile extends StatelessWidget {
  final Course course;
  final CourseEnrollment enrollment;

  const UserCourseTile({
    super.key,
    required this.course,
    required this.enrollment,
  });

  // ─── helpers ──────────────────────────────────────────────────────────────

  Color get _statusColor {
    switch (enrollment.status) {
      case EnrollmentStatus.active:
        return AppColors.pastelGreen;
      case EnrollmentStatus.ready:
        return AppColors.midBlue;
      case EnrollmentStatus.pending:
        return AppColors.royalYellow;
      case EnrollmentStatus.cancelled:
        return AppColors.neutral500;
    }
  }

  String get _statusLabel {
    switch (enrollment.status) {
      case EnrollmentStatus.active:
        return 'نشط';
      case EnrollmentStatus.ready:
        return 'جاهز';
      case EnrollmentStatus.pending:
        return 'معلق';
      case EnrollmentStatus.cancelled:
        return 'ملغي';
    }
  }

  IconData get _subjectIcon {
    switch (course.subject) {
      case Subject.geography:
        return Icons.public_rounded;
      case Subject.history:
        return Icons.history_edu_rounded;
    }
  }

  // Computed from progressMap: completed lessons / total lessons.
  double get _progress {
    final total = course.lessons.length;
    if (total == 0) return 0.0;
    final completed = enrollment.progressMap.values
        .where((v) => v is Map && (v)['isCompleted'] == true)
        .length;
    return (completed / total).clamp(0.0, 1.0);
  }

  Color get _progressColor {
    final p = _progress;
    if (p >= 0.7) return AppColors.pastelGreen;
    if (p >= 0.35) return AppColors.midBlue;
    return AppColors.royalYellow;
  }

  String _fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();
    final pct = (_progress * 100).clamp(0, 100).toInt();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor.withAlpha(35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: icon  |  title + subject  |  status badge ───────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject icon tile
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.midBlue.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_subjectIcon, color: AppColors.midBlue, size: 20),
              ),

              const SizedBox(width: 12),

              // Title + grade · subject
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: shahr.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${course.grade.label}  ·  ${course.subject.label}',
                      style: amiri.copyWith(
                        fontSize: 12,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Status badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _statusColor.withAlpha(55),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _statusLabel,
                      style: amiri.copyWith(
                        fontSize: 12,
                        color: _statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: AppColors.neutral600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'تسجيل : ${_fmt(enrollment.enrolledAt)}',
                        style: amiri.copyWith(
                          fontSize: 12,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Progress bar ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 7,
                    backgroundColor: AppColors.neutral800,
                    valueColor: AlwaysStoppedAnimation(_progressColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$pct%',
                style: amiri.copyWith(
                  fontSize: 12,
                  color: _progressColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Dates row ──────────────────────────────────────────────────────
        ],
      ),
    );
  }
}
