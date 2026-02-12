import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/sub_button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/admin_courses_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/admin_courses_state.dart';
import 'package:mrmichaelashrafdashboard/features/courses/presentation/widgets/admin_course_card.dart';
import 'package:mrmichaelashrafdashboard/features/courses/presentation/widgets/courses_analytics_section.dart';
import 'package:mrmichaelashrafdashboard/shared/components/dashboard_screen_header.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/shared/components/grading_filters.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_default_screen.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_sub_button.dart';

class CoursesCenter extends StatefulWidget {
  const CoursesCenter({super.key});

  @override
  State<CoursesCenter> createState() => _CoursesCenterState();
}

class _CoursesCenterState extends State<CoursesCenter> {
  Grade _selectedGrade = Grade.allGrades;
  List<Course> allCourses = [];
  // Holds the current refresh action to avoid duplicate refresh triggers.
  Future<void>? _refreshFuture;

  @override
  void initState() {
    super.initState();
    context.read<AdminCoursesCubit>().fetchAllCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: BlocConsumer<AdminCoursesCubit, AdminCoursesState>(
        listener: (context, state) {
          if (state is CoursesLoaded) {
            setState(() {
              allCourses = state.courses;
            });
          } else if (state is CoursesError) {
            DashboardHelper.showErrorBar(context, error: state.message);
          }
        },
        builder: (context, state) {
          final List<Course> displayedCourses = allCourses;
          final bool emptyCourseList = displayedCourses.isEmpty;
          final bool isLoading = state is CoursesLoading;

          return RefreshIndicator(
            // Dark card background keeps pull-down ink consistent with UI.
            backgroundColor: AppColors.cardDark,
            // Spinner uses the midblue brand color.
            color: AppColors.midBlue,
            // Pull-to-refresh re-fetches courses for the active grade filter.
            onRefresh: () {
              _refreshFuture ??= _refreshCourses().whenComplete(() {
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

                  // HEADER — TITLE
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: DashboardScreenHeader(
                      title: 'الكورسات',
                      describtion:
                          'إدارة وعرض جميع الكورسات المتاحة في التطبيق',
                    ),
                  ),

                  // ANALYTICS
                  if (!isLoading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: CoursesAnalyticsSection(courses: displayedCourses),
                    ),

                  // ADD NEW COURSE BUTTON
                  Align(
                    alignment: AlignmentGeometry.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 70,
                        horizontal: 20,
                      ),
                      child: SizedBox(
                        width: 230,
                        child: AppSubButton(
                          backgroundColor: AppColors.royalBlue,
                          title: 'أضافه كورس جديد',
                          onTap: () => DashboardHelper.showCoursesManager(
                            context: context,
                          ),
                          state: SubButtonState.idle,
                        ),
                      ),
                    ),
                  ),

                  // FILTERS
                  GradingFilters(
                    selectedGrade: _selectedGrade,
                    onChanged: (selectedValue) {
                      setState(() => _selectedGrade = selectedValue);

                      if (selectedValue == Grade.allGrades) {
                        context.read<AdminCoursesCubit>().fetchAllCourses();
                      } else {
                        context.read<AdminCoursesCubit>().fetchCoursesByGrade(
                          selectedValue.name,
                        );
                      }
                    },
                  ),

                  // LOADING
                  if (isLoading)
                    SizedBox(
                      height: 300,
                      child: Center(child: DashboardHelper.appCircularInd),
                    )
                  // GRID
                  else if (!emptyCourseList)
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
                            itemCount: displayedCourses.length,
                            itemBuilder: (context, index) {
                              final course = displayedCourses[index];
                              return AdminCourseCard(
                                title: course.title,
                                describtion: course.description,
                                numberOfLessons: course.lessons.length,
                                grade: course.grade.label,
                                studentsCount: course.enrollmentCount,
                                price: course.price,
                                imageUrl: course.background,
                                onTap: () {
                                  DashboardHelper.showCoursesManager(
                                    context: context,
                                    existingCourse: course,
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    )
                  // EMPTY STATE
                  else
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: AppDefaultScreen(
                        message: _selectedGrade == Grade.allGrades
                            ? AppStrings.emptyStates.noPublishedCourses
                            : AppStrings.emptyStates.noCoursesForGrade,
                        animationPath: AppAssets.animations.emptyCoursesList,
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

  // Decides which fetch action should run for the currently selected grade.
  Future<void> _refreshCourses() {
    final cubit = context.read<AdminCoursesCubit>();
    if (_selectedGrade == Grade.allGrades) {
      return cubit.fetchAllCourses();
    }
    return cubit.fetchCoursesByGrade(_selectedGrade.name);
  }
}
