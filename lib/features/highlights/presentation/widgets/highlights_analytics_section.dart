import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';
import 'package:mrmichaelashrafdashboard/shared/components/analytics_card.dart';

class HighlightsAnalyticsSection extends StatelessWidget {
  final List<Highlight> highlights;

  const HighlightsAnalyticsSection({super.key, required this.highlights});

  @override
  Widget build(BuildContext context) {
    // Calculate Analytics
    final totalHighlights = highlights.length;
    final activeHighlights = highlights.where((h) => h.isActive()).length;
    final inactiveHighlights = totalHighlights - activeHighlights;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          AnalyticsCard(
            title: 'إجمالي الملاحظات',
            value: '$totalHighlights',
            icon: FontAwesomeIcons.bullhorn,
            color: AppColors.royalBlue,
          ),
          const SizedBox(width: 15),
          AnalyticsCard(
            title: 'الملاحظات النشطة',
            value: '$activeHighlights',
            icon: FontAwesomeIcons.circleCheck,
            color: AppColors.emeraldGreen,
          ),
          const SizedBox(width: 15),
          AnalyticsCard(
            title: 'غير النشطة',
            value: '$inactiveHighlights',
            icon: FontAwesomeIcons.circleXmark,
            color: AppColors.tomatoRed,
          ),
        ],
      ),
    );
  }
}
