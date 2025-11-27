import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_gaps.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/grade.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Logic/Cubits/AdminFunctions/admin_functions_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Presentation/Widgets/admin_studen_card.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Presentation/Widgets/dashboard_screen_header.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/grading_filters.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/app_default_screen.dart';
import 'package:mrmichaelashrafdashboard/Shared/Models/user.dart';

class StudentsCenter extends StatefulWidget {
  const StudentsCenter({super.key});

  @override
  State<StudentsCenter> createState() => _StudentsCenterState();
}

class _StudentsCenterState extends State<StudentsCenter> {
  Grade _selectedGrade = Grade.allGrades;
  List<AppUser> allStudents = [];

  @override
  void initState() {
    super.initState();
    context.read<AdminFunctionsCubit>().fetchAllStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: BlocConsumer<AdminFunctionsCubit, AdminFunctionsState>(
        listener: (context, state) {
          if (state is AdminStudentsLoaded) {
            setState(() => allStudents = state.students);
          } else if (state is AdminFunctionsError) {
            AppHelper.showErrorBar(context, error: state.error);
          }
        },
        builder: (context, state) {
          final students = allStudents;
          final isEmpty = students.isEmpty;
          final isLoading = state is AdminLoadingStudents;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: AppHelper.screenWidth > 600
                      ? 20
                      : AppHelper.getDashboardBarTopSpacing(context),
                ),

                //   --------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: DashboardScreenHeader(
                    title: 'المستخدمين',
                    describtion: 'عرض جميع الطلاب والمستخدمين',
                  ),
                ),

                // FILTERS -------------------------------------------------------
                GradingFilters(
                  onChanged: (selectedValue) {
                    setState(() => _selectedGrade = selectedValue);

                    if (_selectedGrade == Grade.allGrades) {
                      context.read<AdminFunctionsCubit>().fetchAllStudents();
                    } else {
                      context.read<AdminFunctionsCubit>().fetchStudentsByGrade(
                        _selectedGrade.name,
                      );
                    }
                  },
                ),

                // STUDENTS GRID --------------------------------------------------
                if (!isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth < 600
                            ? 1
                            : constraints.maxWidth < 1000
                            ? 2
                            : constraints.maxWidth < 1400
                            ? 3
                            : 4;

                        return MasonryGridView.count(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return AdminStudentCard(student: student);
                          },
                        );
                      },
                    ),
                  )
                // LOADING -------------------------------------------------------
                else if (isLoading)
                  SizedBox(
                    height: 300,
                    child: Center(child: AppHelper.appCircularInd),
                  )
                // EMPTY STATE ---------------------------------------------------
                else
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: AppDefaultScreen(
                      message: _selectedGrade == Grade.allGrades
                          ? AppStrings.emptyStates.noStudents
                          : AppStrings.emptyStates.noStudentsForGrade,
                      animationPath: AppAssets.animations.emptyCoursesList,
                    ),
                  ),

                AppGaps.v20,
              ],
            ),
          );
        },
      ),
    );
  }
}
