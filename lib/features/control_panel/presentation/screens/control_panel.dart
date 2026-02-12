import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/sub_button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/admin_courses_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/admin_courses_state.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/admin_exams_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/admin_exams_state.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/admin_highlights_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/admin_highlights_state.dart';
import 'package:mrmichaelashrafdashboard/features/dashboard/logic/dashboard_center_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/courses/presentation/widgets/admin_course_card.dart';
import 'package:mrmichaelashrafdashboard/features/exams/presentation/widgets/admin_exam_card.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/presentation/widgets/admin_highlight_card.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';
import 'package:mrmichaelashrafdashboard/core/enums/exam_status.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_sub_button.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  List<Course> _courses = [];
  List<Exam> _exams = [];
  List<Highlight> _highlights = [];
  // Keeps track of the ongoing dashboard refresh action.
  Future<void>? _refreshFuture;

  // this is just a test comment for github desktop app

  @override
  void initState() {
    super.initState();
    context.read<AdminCoursesCubit>().fetchAllCourses();
    context.read<AdminExamsCubit>().fetchAllExams();
    context.read<AdminHighlightsCubit>().fetchAllHighlights();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AdminCoursesCubit, AdminCoursesState>(
          listener: (context, state) {
            if (state is CoursesLoaded) {
              setState(() {
                _courses = state.courses;
                _courses.sort(
                  (a, b) => b.enrollmentCount.compareTo(a.enrollmentCount),
                );
              });
            } else if (state is CoursesError) {
              DashboardHelper.showErrorBar(context, error: state.message);
            }
          },
        ),
        BlocListener<AdminExamsCubit, AdminExamsState>(
          listener: (context, state) {
            if (state is ExamsLoaded) {
              setState(() => _exams = state.exams);
            } else if (state is ExamsError) {
              DashboardHelper.showErrorBar(context, error: state.message);
            }
          },
        ),
        BlocListener<AdminHighlightsCubit, AdminHighlightsState>(
          listener: (context, state) {
            if (state is HighlightsLoaded) {
              setState(() => _highlights = state.highlights);
            } else if (state is HighlightsError) {
              DashboardHelper.showErrorBar(context, error: state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.appBlack,
        body: RefreshIndicator(
          backgroundColor: AppColors.cardDark,
          color: AppColors.midBlue,
          onRefresh: () {
            _refreshFuture ??= _refreshDashboard().whenComplete(() {
              _refreshFuture = null;
            });
            return _refreshFuture!;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: DashboardHelper.screenWidth > 600
                      ? 20
                      : DashboardHelper.getDashboardBarTopSpacing(context),
                ),

                // ---------------- HEADER ----------------
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        'لوحة التحكم',
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: AppColors.appWhite,
                          height: 2,
                        ),
                      ),
                      Text(
                        'تحكم في كل محتوى تطبيقك من مكان واحد',
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: AppColors.textSecondaryDark,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 100),
                      // BUTTONS
                      (MediaQuery.of(context).size.width < 900)
                          ? Column(
                              children: [
                                SizedBox(
                                  width: 230,
                                  child: AppSubButton(
                                    backgroundColor: AppColors.royalBlue,
                                    title: 'أضافه كورس جديد',
                                    onTap: () =>
                                        DashboardHelper.showCoursesManager(
                                          context: context,
                                        ),
                                    state: SubButtonState.idle,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                SizedBox(
                                  width: 230,
                                  child: AppSubButton(
                                    backgroundColor: AppColors.royalBlue,
                                    title: 'أضافه امتحان جديد',
                                    onTap: () =>
                                        DashboardHelper.showExamsManager(
                                          context: context,
                                        ),
                                    state: SubButtonState.idle,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                SizedBox(
                                  width: 230,
                                  child: AppSubButton(
                                    backgroundColor: AppColors.royalBlue,
                                    title: 'نشر ملاحظة جديدة',
                                    onTap: () =>
                                        DashboardHelper.showHighlightManagerSheet(
                                          context: context,
                                        ),
                                    state: SubButtonState.idle,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 230,
                                  child: AppSubButton(
                                    backgroundColor: AppColors.royalBlue,
                                    title: 'أضافه كورس جديد',
                                    onTap: () =>
                                        DashboardHelper.showCoursesManager(
                                          context: context,
                                        ),
                                    state: SubButtonState.idle,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                SizedBox(
                                  width: 230,
                                  child: AppSubButton(
                                    backgroundColor: AppColors.royalBlue,
                                    title: 'أضافه امتحان جديد',
                                    onTap: () =>
                                        DashboardHelper.showExamsManager(
                                          context: context,
                                        ),
                                    state: SubButtonState.idle,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                SizedBox(
                                  width: 230,
                                  child: AppSubButton(
                                    backgroundColor: AppColors.royalBlue,
                                    title: 'نشر ملاحظة جديدة',
                                    onTap: () =>
                                        DashboardHelper.showHighlightManagerSheet(
                                          context: context,
                                        ),
                                    state: SubButtonState.idle,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),

                // ---------------- COURSES GRID ----------------
                Text(
                  'الكورسات الأكثر تسجيلاً',
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.appWhite,
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<AdminCoursesCubit, AdminCoursesState>(
                  builder: (context, state) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth < 600
                            ? 1
                            : constraints.maxWidth < 1000
                            ? 2
                            : constraints.maxWidth < 1400
                            ? 3
                            : 4;

                        if (state is CoursesLoading && _courses.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: DashboardHelper.appCircularInd,
                            ),
                          );
                        }

                        if (_courses.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 50,
                              horizontal: 20,
                            ),
                            child: Center(
                              child: Text(
                                'لا توجد كورسات علي المنصة حالياً',
                                style: GoogleFonts.scheherazadeNew(
                                  fontSize: 16,
                                  color: AppColors.textSecondaryDark,
                                ),
                              ),
                            ),
                          );
                        }
                        return MasonryGridView.count(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _courses.take(7).length,
                          itemBuilder: (context, index) {
                            final course = _courses[index];
                            return AdminCourseCard(
                              title: course.title,
                              describtion: course.description,
                              numberOfLessons: course.lessons.length,
                              grade: course.grade.label,
                              studentsCount: course.enrollmentCount,
                              imageUrl: course.background!,
                              price: course.price,
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
                    );
                  },
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () => context
                      .read<DashboardCenterCubit>()
                      .navigateToCoursesCenter(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'عرض جميع الكورسات',
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 14,
                          color: AppColors.skyBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        FontAwesomeIcons.list,
                        size: 13,
                        color: AppColors.skyBlue,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 70),

                // ---------------- EXAMS GRID ----------------
                Text(
                  'الامتحانات النشطة',
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.appWhite,
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<AdminExamsCubit, AdminExamsState>(
                  builder: (context, state) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth < 600
                            ? 1
                            : constraints.maxWidth < 1000
                            ? 2
                            : constraints.maxWidth < 1400
                            ? 3
                            : 4;

                        final activeExams = _exams
                            .where(
                              (e) =>
                                  (e.state ?? e.computeAdminExamState()) ==
                                  ExamStatus.active,
                            )
                            .toList();

                        if (state is ExamsLoading && _exams.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: DashboardHelper.appCircularInd,
                            ),
                          );
                        }

                        if (activeExams.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 50,
                              horizontal: 20,
                            ),
                            child: Center(
                              child: Text(
                                'لا توجد امتحانات نشطة حالياً',
                                style: GoogleFonts.scheherazadeNew(
                                  fontSize: 16,
                                  color: AppColors.textSecondaryDark,
                                ),
                              ),
                            ),
                          );
                        }

                        return MasonryGridView.count(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: activeExams.length,
                          itemBuilder: (context, index) {
                            final exam = activeExams[index];
                            return AdminExamCard(
                              examTitle: exam.title,
                              examDescribtion: exam.description ?? '',
                              grade: exam.grade.isNotEmpty
                                  ? exam.grade
                                  : 'غير محدد',
                              isExamActive: true,
                              examState:
                                  exam.state ?? exam.computeAdminExamState(),
                              duration: exam.duration,
                              questionsCount: exam.questions?.length,
                              examDateRange: exam.examDateRange(
                                exam.startTime,
                                exam.endTime,
                              ),
                              onViewExamManager: () {
                                DashboardHelper.showExamsManager(
                                  context: context,
                                  existingExam: exam,
                                );
                              },
                              onViewResults: () {
                                DashboardHelper.showExamResultsSheet(
                                  context: context,
                                  exam: exam,
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => context
                      .read<DashboardCenterCubit>()
                      .navigateToExamsCenter(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'عرض جميع الامتحانات',
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 14,
                          color: AppColors.skyBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        FontAwesomeIcons.list,
                        size: 13,
                        color: AppColors.skyBlue,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 70),

                // ---------------- HIGHLIGHTS SECTION ----------------
                Text(
                  'الملاحظات النشطة',
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.appWhite,
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<AdminHighlightsCubit, AdminHighlightsState>(
                  builder: (context, state) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth < 600
                            ? 1
                            : constraints.maxWidth < 1000
                            ? 2
                            : constraints.maxWidth < 1400
                            ? 3
                            : 4;

                        final activeHighlights = _highlights
                            .where((h) => h.isActive())
                            .toList();

                        if (state is HighlightsLoading && _highlights.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: DashboardHelper.appCircularInd,
                            ),
                          );
                        }

                        if (activeHighlights.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 50,
                              horizontal: 20,
                            ),
                            child: Center(
                              child: Text(
                                'لا توجد ملاحظات نشطة حالياً',
                                style: GoogleFonts.scheherazadeNew(
                                  fontSize: 16,
                                  color: AppColors.textSecondaryDark,
                                ),
                              ),
                            ),
                          );
                        }

                        return MasonryGridView.count(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: activeHighlights.length,
                          itemBuilder: (context, index) {
                            return AdminHighlightCard(
                              highlight: activeHighlights[index],
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () => context
                      .read<DashboardCenterCubit>()
                      .navigatetoActiveHighlights(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'عرض جميع الملاحظات',
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 14,
                          color: AppColors.skyBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        FontAwesomeIcons.arrowUpRightFromSquare,
                        size: 13,
                        color: AppColors.skyBlue,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Re-fetch all dashboard data so every section gets fresh values.
  Future<void> _refreshDashboard() async {
    await Future.wait([
      context.read<AdminCoursesCubit>().fetchAllCourses(),
      context.read<AdminExamsCubit>().fetchAllExams(),
      context.read<AdminHighlightsCubit>().fetchAllHighlights(),
    ]);
  }
}
