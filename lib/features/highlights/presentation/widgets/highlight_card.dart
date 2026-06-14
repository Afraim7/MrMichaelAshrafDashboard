import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/highlights_types.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/highlights_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/highlights_state.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/app_badge.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/dashboard_card.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/dashboard_card_visibility_toggle.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/meta_row_badge.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';

class HighlightCard extends StatelessWidget {
  final Highlight highlight;
  const HighlightCard({super.key, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final isActive = _isHighlightActive(highlight.startTime, highlight.endTime);

    // Hidden → faded, so the admin can see which notes aren't live yet.
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: highlight.isVisible ? 1.0 : 0.55,
      child: DashboardCard(
        shadowColor: isActive ? AppColors.pastelGreen : AppColors.midBlue,
        onTap: () => DashboardHelper.showHighlightManagerSheet(
          context: context,
          existingHighlight: highlight,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TOP ROW — badges only (no more 3-dots menu)
                  Row(
                    children: [
                      AppBadge(
                        text: highlight.grade.label,
                        badgeColor: AppColors.midBlue,
                      ),
                      const SizedBox(width: 6),
                      AppBadge(
                        text: highlight.type.label,
                        badgeColor: AppColors.skyBlue,
                      ),
                      Spacer(),

                      _HighlightVisibilityToggle(highlight: highlight),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // MESSAGE
                  Flexible(
                    child: Text(
                      highlight.message,
                      style: GoogleFonts.scheherazadeNew(
                        fontSize: 18,
                        color: AppColors.appWhite,
                        height: 1.7,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Divider
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(
                      height: 0.7,
                      color: Color.fromARGB(11, 255, 255, 255),
                    ),
                  ),

                  // DATE ROW
                  Row(
                    children: [
                      Expanded(
                        child: MetaRowBadge(
                          icon: Icons.calendar_month,
                          data: _formatDateRange(
                            highlight.startTime,
                            highlight.endTime,
                          ),
                          dataColor: Colors.white70,
                        ),
                      ),
                      if (isActive)
                        AppBadge(
                          text: 'نشط',
                          badgeColor: AppColors.pastelGreen,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
    return 'حتى ${endDate!.year}/${endDate.month}/${endDate.day}';
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

// ─────────────────────────────────────────────────────────────────────────────
// Bloc-connected visibility toggle. Reads `isVisible` straight off the model
// (the center re-fetches the page on a successful toggle, so the glyph flips
// once the write persists) and shows a per-card spinner while the matching
// `ToggleHighlightVisibilityLoading(id)` is in flight. The id-scoped loading
// state is why one card spinning never spins the rest of the grid.
// ─────────────────────────────────────────────────────────────────────────────

class _HighlightVisibilityToggle extends StatelessWidget {
  final Highlight highlight;
  const _HighlightVisibilityToggle({required this.highlight});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HighlightsCubit, HighlightsState>(
      buildWhen: (prev, curr) =>
          curr is ToggleHighlightVisibilityLoading ||
          curr is ToggleHighlightVisibilitySuccess ||
          curr is ToggleHighlightVisibilityError,
      builder: (context, state) {
        final isUpdating =
            state is ToggleHighlightVisibilityLoading &&
            state.highlightId == highlight.id;

        return DashboardCardVisibilityToggle(
          isVisible: highlight.isVisible,
          isUpdating: isUpdating,
          compact: true,
          onChanged: (next) =>
              context.read<HighlightsCubit>().toggleHighlightVisibility(
                highlightId: highlight.id,
                isVisible: next,
              ),
        );
      },
    );
  }
}
