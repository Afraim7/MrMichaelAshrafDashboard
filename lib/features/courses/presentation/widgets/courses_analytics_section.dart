import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/shared/components/analytics_card.dart';

class CoursesAnalyticsSection extends StatelessWidget {
  final List<Course> courses;

  const CoursesAnalyticsSection({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    // Calculate Analytics
    final totalCourses = courses.length;
    final totalStudents = courses.fold<int>(
      0,
      (previousValue, course) => previousValue + course.enrollmentCount,
    );
    final totalSubscriptions = courses.fold<int>(
      0,
      (previousValue, course) => previousValue + course.enrollmentCount,
    );
    final totalRevenue = courses.fold<double>(
      0,
      (previousValue, course) =>
          previousValue + (course.price * course.enrollmentCount),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          AnalyticsCard(
            title: 'إجمالي الإيرادات',
            value: '${totalRevenue.toStringAsFixed(0)} \$',
            icon: FontAwesomeIcons.sackDollar,
            color: AppColors.emeraldGreen,
          ),
          const SizedBox(width: 15),
          AnalyticsCard(
            title: 'عدد الكورسات',
            value: '$totalCourses',
            icon: FontAwesomeIcons.bookOpen,
            color: AppColors.posterRed,
          ),
          const SizedBox(width: 15),
          AnalyticsCard(
            title: 'عدد الاشتراكات',
            value: '$totalSubscriptions',
            icon: FontAwesomeIcons.userCheck,
            color: AppColors.royalBlue,
          ),
          const SizedBox(width: 15),
          AnalyticsCard(
            title: 'إجمالي الطلاب',
            value: '$totalStudents',
            icon: FontAwesomeIcons.users,
            color: AppColors.energyOrange,
          ),
        ],
      ),
    );
  }
}
