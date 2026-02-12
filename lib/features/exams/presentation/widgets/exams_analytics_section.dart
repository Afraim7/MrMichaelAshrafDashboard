import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/shared/components/analytics_card.dart';

class ExamsAnalyticsSection extends StatelessWidget {
  final List<Exam> exams;

  const ExamsAnalyticsSection({super.key, required this.exams});

  @override
  Widget build(BuildContext context) {
    // Calculate Analytics
    final totalExams = exams.length;
    final activeExams = exams.where((e) => e.isActive()).length;

    // Note: These are placeholder values since exam results are not fetched here
    // In production, you would need to fetch exam results and calculate actual rates
    final successRate = '0'; // Placeholder
    final failureRate = '0'; // Placeholder

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          AnalyticsCard(
            title: 'إجمالي الامتحانات',
            value: '$totalExams',
            icon: FontAwesomeIcons.fileLines,
            color: AppColors.royalBlue,
          ),
          const SizedBox(width: 15),
          AnalyticsCard(
            title: 'الامتحانات النشطة',
            value: '$activeExams',
            icon: FontAwesomeIcons.clock,
            color: AppColors.emeraldGreen,
          ),
          const SizedBox(width: 15),
          AnalyticsCard(
            title: 'نسبة النجاح',
            value: '$successRate%',
            icon: FontAwesomeIcons.circleCheck,
            color: AppColors.pastelGreen,
          ),
          const SizedBox(width: 15),
          AnalyticsCard(
            title: 'نسبة الرسوب',
            value: '$failureRate%',
            icon: FontAwesomeIcons.circleXmark,
            color: AppColors.tomatoRed,
          ),
        ],
      ),
    );
  }
}
