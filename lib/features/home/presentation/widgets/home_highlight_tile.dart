import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/highlights_types.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/dashboard_card.dart';

/// Slim highlight tile for the home preview grid.
///
/// Highlights are almost entirely about the message text + grade context —
/// so this tile gives the message room to breathe (3 lines) and shows only
/// the grade chip + type as supporting info.
class HomeHighlightTile extends StatelessWidget {
  final Highlight highlight;
  const HomeHighlightTile({super.key, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();

    return DashboardCard(
      onTap: () => DashboardHelper.showHighlightManagerSheet(
        context: context,
        existingHighlight: highlight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grade + type chip row
            Row(
              children: [
                _MiniChip(
                  label: highlight.grade.label,
                  color: AppColors.midBlue,
                ),
                const SizedBox(width: 6),
                _MiniChip(
                  label: highlight.type.label,
                  color: AppColors.skyBlue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // The message — the actual content of a highlight
            Text(
              highlight.message,
              style: shahr.copyWith(
                fontSize: 18,
                color: AppColors.appWhite,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
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
                    _dateRange(highlight),
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

  String _dateRange(Highlight h) {
    String fmt(DateTime? d) =>
        d == null ? '—' : '${d.day}/${d.month}/${d.year}';
    if (h.startTime == null && h.endTime == null) return '—';
    return '${fmt(h.startTime)}  →  ${fmt(h.endTime)}';
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
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
