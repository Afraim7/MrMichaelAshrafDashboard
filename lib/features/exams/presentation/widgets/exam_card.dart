import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/enums/button_state.dart';
import 'package:mrmichaelashrafdashboard/core/enums/exam_status.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/exams_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/exams_state.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/app_sub_button.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/dashboard_card.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/dashboard_card_visibility_toggle.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/meta_row_badge.dart';

/// Grid card for a single exam in the admin centers.
///
/// Visual hierarchy (top → bottom):
///   1. Header row — state pill + grade pill on the right, visibility toggle
///      on the left. The state pill's accent color cascades into the rest
///      of the card so admins instantly read "active / done / upcoming".
///   2. Title + description (2 lines, dimmer).
///   3. 2×2 mini-tile grid — questions, duration, marks, date range.
///      Much faster to scan than the previous stacked-MetaRow list.
///   4. Footer button — "عرض النتائج", tinted with the state accent so it
///      visibly belongs to this exam.
class ExamCard extends StatelessWidget {
  final String examId;
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
  final int? finishedUsersCount;
  final VoidCallback? onLongPress;

  /// Admin visibility flag. Hidden exams render dimmed so the admin can see
  /// at a glance which ones aren't live for students yet.
  final bool isVisible;

  const ExamCard({
    super.key,
    required this.examId,
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
    this.finishedUsersCount,
    this.onLongPress,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    final accent = examState.getStateColor;
    final hasDescription = examDescribtion.trim().isNotEmpty;

    // Hidden → faded.
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isVisible ? 1.0 : 0.55,
      child: DashboardCard(
        shadowColor: accent,
        // Whole card opens the exam manager (edit/delete). The "View Results"
        // button below is a separate dedicated action.
        onTap: onViewExamManager,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── HEADER: visibility + status + grade ────────────────────
              Row(
                children: [
                  _StatusPill(label: examState.label, color: accent),
                  const SizedBox(width: 6),
                  _StatusPill(
                    label: grade,
                    color: AppColors.skyBlue,
                    outlined: true,
                  ),
                  const Spacer(),

                  _ExamVisibilityToggle(examId: examId, isVisible: isVisible),
                ],
              ),

              const SizedBox(height: 16),

              // ── TITLE + DESCRIPTION ───────────────────────────────────
              Text(
                examTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 19,
                  color: AppColors.appWhite,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              if (hasDescription) ...[
                const SizedBox(height: 6),
                Text(
                  examDescribtion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 14,
                    color: AppColors.textSecondaryDark,
                    height: 1.5,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              _StatTilesGrid(
                questionsCount: questionsCount,
                duration: duration,
                fullMark: examFullMark,
                dateRange: examDateRange,
                accent: accent,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: MetaRowBadge(
                      icon: Icons.calendar_month,
                      data: examDateRange,
                      dataColor: Colors.white70,
                    ),
                  ),
                  if (finishedUsersCount != null) ...[
                    const SizedBox(width: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.group_rounded,
                          size: 17,
                          color: AppColors.neutral600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$finishedUsersCount',
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 17,
                            color: Colors.white70,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // ── FOOTER BUTTON ──────────────────────────────────────────
              AppSubButton(
                title: 'عرض النتائج',
                titleSize: 16,
                backgroundColor: AppColors.cardDark.withAlpha(90),
                onTap: onViewResults ?? () {},
                state: ButtonState.idle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamVisibilityToggle extends StatelessWidget {
  final String examId;
  final bool isVisible;

  const _ExamVisibilityToggle({required this.examId, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExamsCubit, ExamsState>(
      buildWhen: (prev, curr) =>
          curr is ToggleExamVisibilityLoading ||
          curr is ToggleExamVisibilitySuccess ||
          curr is ToggleExamVisibilityError,
      builder: (context, state) {
        final isUpdating =
            state is ToggleExamVisibilityLoading && state.examId == examId;

        return DashboardCardVisibilityToggle(
          isVisible: isVisible,
          isUpdating: isUpdating,
          compact: true,
          onChanged: (next) => context.read<ExamsCubit>().toggleExamVisibility(
            examId: examId,
            isVisible: next,
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;

  const _StatusPill({
    required this.label,
    required this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withAlpha(outlined ? 90 : 60),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.amiri(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatTilesGrid extends StatelessWidget {
  final int? questionsCount;
  final int? duration;
  final int? fullMark;
  final String? dateRange;
  final Color accent;

  const _StatTilesGrid({
    required this.questionsCount,
    required this.duration,
    required this.fullMark,
    required this.dateRange,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      if (questionsCount != null)
        _MiniTile(
          icon: Icons.quiz,
          value: '$questionsCount',
          label: 'سؤال',
          color: AppColors.midBlue,
        ),
      if (duration != null)
        _MiniTile(
          icon: Icons.timer_outlined,
          value: '$duration',
          label: 'دقيقة',
          color: AppColors.energyOrange,
        ),
      if (fullMark != null)
        _MiniTile(
          icon: Icons.sports_score_rounded,
          value: '$fullMark',
          label: 'درجة',
          color: AppColors.emeraldGreen,
        ),
    ];

    if (tiles.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 8, runSpacing: 8, children: tiles);
  }
}

class _MiniTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(35), width: 1),
      ),
      // No Flexible wrapper — Flexible requires a Flex parent (Row/Column),
      // not a Container. Wrapping a Column in Flexible here produced a
      // sizeless render box, which propagated up the card tree and tripped
      // the "hit test on render box with no size" assertion on hover.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.amiri(
              fontSize: 15,
              color: AppColors.appWhite,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.amiri(
              fontSize: 14,
              color: AppColors.neutral500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
