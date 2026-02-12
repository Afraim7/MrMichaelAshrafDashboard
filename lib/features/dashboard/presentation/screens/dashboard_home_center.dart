import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/features/dashboard/logic/dashboard_center_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/dashboard/presentation/widgets/dashboard_bar.dart';
import 'package:mrmichaelashrafdashboard/features/control_panel/presentation/screens/control_panel.dart';
import 'package:mrmichaelashrafdashboard/features/courses/presentation/screens/courses_center.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/presentation/screens/highlights_center.dart';
import 'package:mrmichaelashrafdashboard/features/exams/presentation/screens/exams_center.dart';
import 'package:mrmichaelashrafdashboard/features/students/presentation/widgets/students_center.dart';

class DashboardHomeCenter extends StatelessWidget {
  const DashboardHomeCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                right: isDesktop ? 80 : 0,
                top: isDesktop ? 0 : 80,
              ),
              child: BlocBuilder<DashboardCenterCubit, int>(
                builder: (context, currentIndex) {
                  return IndexedStack(
                    index: currentIndex,
                    children: const [
                      ControlPanel(),
                      CoursesCenter(),
                      HighlightsCenter(),
                      ExamsCenter(),
                      StudentsCenter(),
                    ],
                  );
                },
              ),
            ),
          ),

          Align(
            alignment: isDesktop ? Alignment.centerRight : Alignment.topCenter,
            child: isDesktop
                ? const DashboardBar()
                : const SafeArea(child: DashboardBar()),
          ),
        ],
      ),
    );
  }
}
