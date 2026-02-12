import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/students/logic/admin_students_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/students/logic/admin_students_state.dart';
import 'package:mrmichaelashrafdashboard/features/students/presentation/widgets/admin_studen_card.dart';
import 'package:mrmichaelashrafdashboard/features/students/presentation/widgets/students_analytics_section.dart';
import 'package:mrmichaelashrafdashboard/shared/components/dashboard_screen_header.dart';
import 'package:mrmichaelashrafdashboard/shared/components/grading_filters.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_default_screen.dart';
import 'package:mrmichaelashrafdashboard/features/students/data/models/user.dart';

class StudentsCenter extends StatefulWidget {
  const StudentsCenter({super.key});

  @override
  State<StudentsCenter> createState() => _StudentsCenterState();
}

class _StudentsCenterState extends State<StudentsCenter> {
  Grade _selectedGrade = Grade.allGrades;
  List<AppUser> allStudents = [];
  // Cached refresh future ensures only one refresh operation runs at a time.
  Future<void>? _refreshFuture;

  @override
  void initState() {
    super.initState();
    context.read<AdminStudentsCubit>().fetchAllStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: BlocConsumer<AdminStudentsCubit, AdminStudentsState>(
        listener: (context, state) {
          if (state is StudentsLoaded) {
            setState(() => allStudents = state.students);
          } else if (state is StudentsError) {
            DashboardHelper.showErrorBar(context, error: state.message);
          }
        },
        builder: (context, state) {
          final students = allStudents;
          final isEmpty = students.isEmpty;
          final isLoading = state is StudentsLoading;

          return RefreshIndicator(
            // Card-dark background keeps the refresh sheet cohesive.
            backgroundColor: AppColors.cardDark,
            // Spinner color leverages the midblue accent.
            color: AppColors.midBlue,
            // Pull-to-refresh fetches students for the active grade filter.
            onRefresh: () {
              _refreshFuture ??= _refreshStudents().whenComplete(() {
                _refreshFuture = null;
              });
              return _refreshFuture!;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: DashboardHelper.screenWidth > 600
                        ? 20
                        : DashboardHelper.getDashboardBarTopSpacing(context),
                  ),

                  //   --------------------------------------------------------
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: DashboardScreenHeader(
                      title: 'المستخدمين',
                      describtion: 'عرض جميع الطلاب والمستخدمين',
                    ),
                  ),

                  // ANALYTICS -----------------------------------------------------
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30, left: 20),
                    child: StudentsAnalyticsSection(students: students),
                  ),

                  // FILTERS -------------------------------------------------------
                  GradingFilters(
                    selectedGrade: _selectedGrade,
                    onChanged: (selectedValue) {
                      setState(() => _selectedGrade = selectedValue);

                      if (selectedValue == Grade.allGrades) {
                        context.read<AdminStudentsCubit>().fetchAllStudents();
                      } else {
                        context.read<AdminStudentsCubit>().fetchStudentsByGrade(
                          selectedValue.name,
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
                      child: Center(child: DashboardHelper.appCircularInd),
                    )
                  // EMPTY STATE ---------------------------------------------------
                  else
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: AppDefaultScreen(
                        message: _selectedGrade == Grade.allGrades
                            ? AppStrings.emptyStates.noStudents
                            : AppStrings.emptyStates.noStudentsForGrade,
                        animationPath: AppAssets.animations.emptyStudentsList,
                      ),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Selects the right cubit call according to the currently selected grade.
  Future<void> _refreshStudents() {
    final cubit = context.read<AdminStudentsCubit>();
    if (_selectedGrade == Grade.allGrades) {
      return cubit.fetchAllStudents();
    }
    return cubit.fetchStudentsByGrade(_selectedGrade.name);
  }
}
