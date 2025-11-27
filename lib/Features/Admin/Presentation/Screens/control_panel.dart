import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_gaps.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/grade.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/sub_button_state.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Logic/Cubits/AdminFunctions/admin_functions_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Logic/Cubits/dashboard_center_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Presentation/Widgets/admin_course_card.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Presentation/Widgets/admin_exam_card.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Presentation/Widgets/admin_highlight_card.dart';
import 'package:mrmichaelashrafdashboard/Shared/Models/course.dart';
import 'package:mrmichaelashrafdashboard/Shared/Models/exam.dart';
import 'package:mrmichaelashrafdashboard/Shared/Models/highlight.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/exam_status.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/app_sub_button.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  List<Course> _courses = [];
  List<Exam> _exams = [];
  List<Highlight> _highlights = [];

  @override
  void initState() {
    super.initState();
    context.read<AdminFunctionsCubit>().fetchAllCourses();
    context.read<AdminFunctionsCubit>().fetchAllExams();
    context.read<AdminFunctionsCubit>().fetchAllHighlights();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: BlocConsumer<AdminFunctionsCubit, AdminFunctionsState>(
        listener: (context, state) {
          if (state is AdminFunctionsError) {
            AppHelper.showErrorBar(context, error: state.error);
          } else if (state is AdminCoursesLoaded) {
            setState(() {
              _courses = state.courses;
              // Sort by enrollment count (most enrolled first)
              _courses.sort(
                (a, b) => b.enrollmentCount.compareTo(a.enrollmentCount),
              );
            });
          } else if (state is AdminExamsLoaded) {
            setState(() {
              _exams = state.exams;
            });
          } else if (state is AdminHighlightsLoaded) {
            setState(() {
              _highlights = state.highlights;
            });
          }
        },
        builder: (context, state) {
          if (state is AdminLoadingCourses && _courses.isEmpty) {
            return SizedBox(
              height: 300,
              child: Center(child: AppHelper.appCircularInd),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: AppHelper.screenWidth > 600
                      ? 20
                      : AppHelper.getDashboardBarTopSpacing(context),
                ),

                // ---------------- HEADER ----------------
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: GoogleFonts.poppins(
                          fontSize: 30,
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

                      AppGaps.v16,

                      // BUTTONS
                      (MediaQuery.of(context).size.width < 600)
                          ? Column(
                              children: [
                                SizedBox(
                                  width: 230,
                                  child: AppSubButton(
                                    backgroundColor: AppColors.royalBlue,
                                    title: 'أضافه كورس جديد',
                                    onTap: () => AppHelper.showCoursesManager(
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
                                    onTap: () => AppHelper.showExamsManager(
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
                                    onTap: () => AppHelper.showCoursesManager(
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
                                    onTap: () => AppHelper.showExamsManager(
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

                AppGaps.v16,

                // ---------------- COURSES GRID ----------------
                Text(
                  'الكورسات الأكثر تسجيلاً',
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.appWhite,
                  ),
                ),
                AppGaps.v6,
                LayoutBuilder(
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
                          price: course.price!,
                          onTap: () {
                            AppHelper.showCoursesManager(
                              context: context,
                              existingCourse: course,
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
                      AppGaps.h1,
                      Icon(
                        FontAwesomeIcons.list,
                        size: 13,
                        color: AppColors.skyBlue,
                      ),
                      AppGaps.h1,
                    ],
                  ),
                ),

                AppGaps.v16,

                //                 // ---------------- EXAMS GRID ----------------
                Text(
                  'الامتحانات النشطة',
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.appWhite,
                  ),
                ),
                AppGaps.v6,
                LayoutBuilder(
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
                        .take(7)
                        .toList();

                    if (_exams.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(child: AppHelper.appCircularInd),
                      );
                    }

                    if (activeExams.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
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
                          examState: exam.state ?? exam.computeAdminExamState(),
                          duration: exam.duration,
                          questionsCount: exam.questions?.length,
                          examDateRange: exam.examDateRange(
                            exam.startTime,
                            exam.endTime,
                          ),
                          onViewExamManager: () {
                            AppHelper.showExamsManager(
                              context: context,
                              existingExam: exam,
                            );
                          },
                          onViewResults: () {
                            AppHelper.showExamResultsSheet(
                              context: context,
                              exam: exam,
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
                      AppGaps.h1,
                      Icon(
                        FontAwesomeIcons.list,
                        size: 13,
                        color: AppColors.skyBlue,
                      ),
                      AppGaps.h1,
                    ],
                  ),
                ),

                AppGaps.v16,

                // ---------------- HIGHLIGHTS SECTION ----------------
                Text(
                  'الملاحظات النشطة',
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.appWhite,
                  ),
                ),
                AppGaps.v6,
                LayoutBuilder(
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
                        .take(7)
                        .toList();

                    if (_highlights.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(child: AppHelper.appCircularInd),
                      );
                    }

                    if (activeHighlights.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
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
                      AppGaps.h1,
                      Icon(
                        FontAwesomeIcons.arrowUpRightFromSquare,
                        size: 13,
                        color: AppColors.skyBlue,
                      ),
                      AppGaps.h1,
                    ],
                  ),
                ),

                AppGaps.v10,
              ],
            ),
          );
        },
      ),
    );
  }
}
