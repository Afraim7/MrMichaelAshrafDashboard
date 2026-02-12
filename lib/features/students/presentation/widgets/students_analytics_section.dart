import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mrmichaelashrafdashboard/core/enums/gender.dart';
import 'package:mrmichaelashrafdashboard/core/enums/study_type.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/features/students/data/models/user.dart';
import 'package:mrmichaelashrafdashboard/shared/components/analytics_card.dart';

class StudentsAnalyticsSection extends StatelessWidget {
  final List<AppUser> students;

  const StudentsAnalyticsSection({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    // Calculate Analytics
    final totalStudents = students.length;
    final totalMales = students.where((s) => s.gender == Gender.male).length;
    final totalFemales = students
        .where((s) => s.gender == Gender.female)
        .length;
    final onlineStudents = students
        .where((s) => s.studyType == StudyType.onlineStudent)
        .length;
    final centerStudents = students
        .where((s) => s.studyType == StudyType.centerStudent)
        .length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          AnalyticsCard(
            title: 'إجمالي الطلاب',
            value: '$totalStudents',
            icon: FontAwesomeIcons.users,
            color: AppColors.royalBlue,
          ),
          const SizedBox(width: 15),
          AnalyticsCard(
            title: 'طلاب الآونلاين',
            value: '$onlineStudents',
            icon: FontAwesomeIcons.globe,
            color: AppColors.emeraldGreen,
          ),
          const SizedBox(width: 15),
          AnalyticsCard(
            title: 'طلاب السنتر',
            value: '$centerStudents',
            icon: FontAwesomeIcons.buildingColumns,
            color: AppColors.energyOrange,
          ),
          const SizedBox(width: 15),
          AnalyticsCard(
            title: 'عدد الطلاب',
            value: '$totalMales',
            icon: FontAwesomeIcons.person,
            color: AppColors.skyBlue,
          ),
          const SizedBox(width: 15),
          AnalyticsCard(
            title: 'عدد الطالبات',
            value: '$totalFemales',
            icon: FontAwesomeIcons.personDress,
            color: AppColors.tomatoRed,
          ),
        ],
      ),
    );
  }
}
