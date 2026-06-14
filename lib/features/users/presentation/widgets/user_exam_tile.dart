import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/enums/exam_status.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam_result.dart';

/// Displays a single exam entry for a student inside the admin sheet.
/// Receives only [Exam] and an optional [ExamResult] — no fetch logic here.
class UserExamTile extends StatelessWidget {
  final Exam exam;

  /// Null when the student has not submitted this exam yet.
  final ExamResult? result;

  const UserExamTile({super.key, required this.exam, this.result});

  // ─── helpers ──────────────────────────────────────────────────────────────

  ExamStatus get _resolvedStatus {
    if (result != null) return ExamStatus.completed;
    return exam.computeUserExamState(hasResult: false);
  }

  double get _fullMark => exam.fullExamMark();

  double get _pct {
    if (result == null || _fullMark == 0) return 0;
    return ((result!.score ?? 0) / _fullMark * 100).clamp(0, 100);
  }

  bool get _passed => _pct >= 50;

  Color get _accentColor {
    if (result != null) {
      return _passed ? AppColors.pastelGreen : AppColors.tomatoRed;
    }
    return _resolvedStatus.getStateColor;
  }

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();
    final hasResult = result != null;
    final accent = _accentColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasResult ? accent.withAlpha(15) : AppColors.surfaceAltDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withAlpha(hasResult ? 45 : 28),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: icon  |  title + grade  |  status badge ──────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exam icon tile
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.assignment_rounded, color: accent, size: 20),
              ),

              const SizedBox(width: 12),

              // Title + grade
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      style: shahr.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      exam.grade.label.isNotEmpty ? exam.grade.label : '—',
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
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withAlpha(55), width: 1),
                    ),
                    child: Text(
                      _resolvedStatus.label,
                      style: amiri.copyWith(
                        fontSize: 12,
                        color: accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (result!.submittedAt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 12,
                          color: AppColors.neutral600,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'تسليم: ${_fmt(result!.submittedAt!)}',
                          style: amiri.copyWith(
                            fontSize: 12,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),

          // ── Result section (only when student has submitted) ────────────
          if (hasResult) ...[
            const SizedBox(height: 12),

            Container(height: 1, color: accent.withAlpha(30)),

            const SizedBox(height: 10),

            Row(
              children: [
                // Score fraction
                Text(
                  'النتيجة:',
                  style: amiri.copyWith(
                    fontSize: 12,
                    color: AppColors.neutral500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(result!.score ?? 0).toInt()} / ${_fullMark.toInt()}',
                  style: shahr.copyWith(
                    fontSize: 15,
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Percentage chip
                _ExamChip(label: '${_pct.toStringAsFixed(0)}%', color: accent),
                const SizedBox(width: 5),
                // Pass/fail badge
                _ExamChip(
                  label: _passed ? 'ناجح' : 'راسب',
                  color: accent,
                  filled: true,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Small chip ────────────────────────────────────────────────────────────────

class _ExamChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _ExamChip({
    required this.label,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color.withAlpha(55) : color.withAlpha(22),
        borderRadius: BorderRadius.circular(8),
        border: filled
            ? null
            : Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.amiri(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
