import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin%20Dashboard/Logic/dashboard_center_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Control%20Panel%20/Presentation/Screens/control_panel.dart';
import 'package:mrmichaelashrafdashboard/Features/Courses/Presentation/Screens/courses_center.dart';
import 'package:mrmichaelashrafdashboard/Features/Highlights/Presentation/Screens/highlights_center.dart';
import 'package:mrmichaelashrafdashboard/Features/Exams/Presentation/Screens/exams_center.dart';
import 'package:mrmichaelashrafdashboard/Features/Students/Presentation/Widgets/students_center.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin%20Dashboard/Presentation/Widgets/dashboard_bar.dart';

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
