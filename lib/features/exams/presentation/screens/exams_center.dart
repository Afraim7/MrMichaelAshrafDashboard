import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/sub_button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/admin_exams_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/admin_exams_state.dart';
import 'package:mrmichaelashrafdashboard/features/exams/presentation/widgets/admin_exam_card.dart';
import 'package:mrmichaelashrafdashboard/features/exams/presentation/widgets/exams_analytics_section.dart';
import 'package:mrmichaelashrafdashboard/shared/components/dashboard_screen_header.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/shared/components/grading_filters.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_default_screen.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_sub_button.dart';

class ExamsCenter extends StatefulWidget {
  const ExamsCenter({super.key});

  @override
  State<ExamsCenter> createState() => _ExamsCenterState();
}

class _ExamsCenterState extends State<ExamsCenter> {
  Grade _selectedGrade = Grade.allGrades;
  List<Exam> allExams = [];
  // Keeps single reference to the refresh future so multiple pulls do not overlap.
  Future<void>? _refreshFuture;

  @override
  void initState() {
    super.initState();
    context.read<AdminExamsCubit>().fetchAllExams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: BlocConsumer<AdminExamsCubit, AdminExamsState>(
        listener: (context, state) {
          if (state is ExamsLoaded) {
            setState(() {
              allExams = state.exams;
            });
          } else if (state is ExamsError) {
            DashboardHelper.showErrorBar(context, error: state.message);
          }
        },
        builder: (context, state) {
          final List<Exam> displayedExams = allExams;
          bool emptyExamList = displayedExams.isEmpty;
          bool isLoading = state is ExamsLoading;

          return RefreshIndicator(
            // Use dark card tone so the refresh HUD blends with the design.
            backgroundColor: AppColors.cardDark,
            // Midblue spinner keeps loading feedback on-brand.
            color: AppColors.midBlue,
            // Reload exams list respecting the currently active grade filter.
            onRefresh: () {
              _refreshFuture ??= _refreshExams().whenComplete(() {
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
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: DashboardScreenHeader(
                      title: 'الامتحانات',
                      describtion:
                          'إدارة وعرض جميع الامتحانات المنشورة في التطبيق',
                    ),
                  ),

                  // ANALYTICS
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ExamsAnalyticsSection(exams: displayedExams),
                  ),

                  // ADD NEW EXAM BUTTON
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
                          title: 'أضافه امتحان جديد',
                          onTap: () => DashboardHelper.showExamsManager(
                            context: context,
                          ),
                          state: SubButtonState.idle,
                        ),
                      ),
                    ),
                  ),

                  GradingFilters(
                    selectedGrade: _selectedGrade,
                    onChanged: (selectedValue) {
                      setState(() {
                        _selectedGrade = selectedValue;
                      });

                      if (selectedValue == Grade.allGrades) {
                        context.read<AdminExamsCubit>().fetchAllExams();
                      } else {
                        context.read<AdminExamsCubit>().fetchExamsByGrade(
                          selectedValue.label,
                        );
                      }
                    },
                  ),

                  if (!emptyExamList)
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
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayedExams.length,
                            itemBuilder: (context, index) {
                              final exam = displayedExams[index];
                              return AdminExamCard(
                                examTitle: exam.title,
                                examDescribtion: exam.description ?? '',
                                grade: exam.grade,
                                isExamActive: exam.isActive(),
                                examState:
                                    exam.state ?? exam.computeAdminExamState(),
                                duration: exam.duration,
                                questionsCount: exam.questions?.length,
                                examDateRange: exam.examDateRange(
                                  exam.startTime,
                                  exam.endTime,
                                ),
                                onViewResults: () {
                                  DashboardHelper.showExamResultsSheet(
                                    context: context,
                                    exam: exam,
                                  );
                                },
                                onViewExamManager: () {
                                  DashboardHelper.showExamsManager(
                                    context: context,
                                    existingExam: exam,
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    )
                  else if (isLoading)
                    SizedBox(
                      height: 300,
                      child: Center(child: DashboardHelper.appCircularInd),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: AppDefaultScreen(
                        message: _selectedGrade == Grade.allGrades
                            ? AppStrings.emptyStates.noPublishedExams
                            : AppStrings.emptyStates.noExamsForGrade,
                        // Dedicated empty exams animation instead of reusing courses.
                        animationPath: AppAssets.animations.emptyExamsList,
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

  // Calls the appropriate cubit fetch method based on the selected grade.
  Future<void> _refreshExams() {
    final cubit = context.read<AdminExamsCubit>();
    if (_selectedGrade == Grade.allGrades) {
      return cubit.fetchAllExams();
    }
    return cubit.fetchExamsByGrade(_selectedGrade.label);
  }
}
