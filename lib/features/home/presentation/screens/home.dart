import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/dashboard/logic/dashboard_center_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/home/data/models/top_bar_action.dart';
import 'package:mrmichaelashrafdashboard/features/home/logic/home_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/home/logic/home_state.dart';
import 'package:mrmichaelashrafdashboard/features/home/presentation/widgets/home_analytics_section.dart';
import 'package:mrmichaelashrafdashboard/features/home/presentation/widgets/home_course_tile.dart';
import 'package:mrmichaelashrafdashboard/features/home/presentation/widgets/home_exam_tile.dart';
import 'package:mrmichaelashrafdashboard/features/home/presentation/widgets/home_highlight_tile.dart';
import 'package:mrmichaelashrafdashboard/features/home/presentation/widgets/home_section_header.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';
import 'package:mrmichaelashrafdashboard/features/platform/logic/platform_status_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/platform/presentation/maintainence_live_toggle.dart';
import 'package:mrmichaelashrafdashboard/shared/views/error_view.dart';
import 'package:mrmichaelashrafdashboard/shared/views/loading_view.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/responsive_grid.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/screen_top_bar.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().load();
    // Pull the platform live/maintenance status for the toggle at the top.
    context.read<PlatformStatusCubit>().loadPlatformConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          // Resolve the bundle to render from either terminal success state,
          // or the cached `previous` while a silent refresh is in flight.
          final LoadHomeSuccess? data = switch (state) {
            LoadHomeSuccess s => s,
            RefreshHomeLoading s => s.previous,
            _ => null,
          };

          // Body slot — swapped per state so the ScreenTopBar always renders
          // above. Loading / error never replace the bar; only the section
          // below the bar updates, which keeps the page chrome stable while
          // the bundle resolves.
          final Widget bodySlot;
          if (data == null && state is LoadHomeError) {
            bodySlot = ErrorView(
              message: state.message,
              animationPath: AppAssets.animations.emptyCoursesList,
              onRetry: () => context.read<HomeCubit>().load(),
            );
          } else if (data == null) {
            bodySlot = const Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: LoadingView(),
            );
          } else {
            bodySlot = _HomeBody(data: data);
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              children: [
                ScreenTopBar(
                  title: 'لوحة التحكم',
                  subtitle:
                      'نظرة عامة على نشاط المنصة والإدارة السريعة لأهم الأقسام',
                  actions: [
                    TopBarAction(
                      label: 'إضافة كورس جديد',
                      onPressed: () =>
                          DashboardHelper.showCoursesManager(context: context),
                      isPrimary: true,
                    ),
                    TopBarAction(
                      label: 'إضافة امتحان جديد',
                      onPressed: () =>
                          DashboardHelper.showExamsManager(context: context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                bodySlot,
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — pure render off the resolved [LoadHomeSuccess] bundle.
// ─────────────────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  final LoadHomeSuccess data;
  const _HomeBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MaintainenceLiveToggleConnected(),
        const SizedBox(height: 30),

        // ── ANALYTICS ──────────────────────────────────────────────────
        HomeAnalyticsSection(
          studentsBreakdown: data.breakdown,
          coursesCount: data.totalCoursesCount,
          totalExamsCount: data.totalExamsCount,
          activeExamsCount: data.activeExamsCount,
          totalHighlightsCount: data.totalHighlightsCount,
          activeHighlightsCount: data.activeHighlightsCount,
          totalEnrollmentsCount: data.totalEnrollmentsCount,
          totalRevenue: data.totalRevenue,
        ),
        const SizedBox(height: 70),

        if (data.isCompletelyEmpty) ...[
          const _FirstLaunchEmptyState(),
          const SizedBox(height: 30),
        ] else ...[
          // ── TOP COURSES ──────────────────────────────────────────────
          HomeSectionHeader(
            title: 'الكورسات الأكثر تسجيلاً',
            actionText: 'عرض الكل',
            onViewAll: () =>
                context.read<DashboardCenterCubit>().navigateToCoursesCenter(),
          ),
          _SectionGrid<Course>(
            items: data.topCourses,
            emptyLabel: 'لا توجد كورسات علي المنصة حالياً',
            itemBuilder: (c) => HomeCourseTile(course: c),
          ),

          const SizedBox(height: 70),

          // ── LIVE EXAMS ───────────────────────────────────────────────
          HomeSectionHeader(
            title: 'الأمتحانات الجارية',
            actionText: 'عرض الكل',
            onViewAll: () =>
                context.read<DashboardCenterCubit>().navigateToExamsCenter(),
          ),
          _SectionGrid<Exam>(
            items: data.liveExams,
            emptyLabel: 'لا توجد امتحانات نشطة حالياً',
            itemBuilder: (e) => HomeExamTile(exam: e),
          ),

          const SizedBox(height: 70),

          // ── LIVE HIGHLIGHTS ──────────────────────────────────────────
          HomeSectionHeader(
            title: 'الملاحظات النشطة',
            actionText: 'عرض الكل',
            onViewAll: () => context
                .read<DashboardCenterCubit>()
                .navigatetoActiveHighlights(),
          ),
          _SectionGrid<Highlight>(
            items: data.liveHighlights,
            emptyLabel: 'لا توجد ملاحظات نشطة حالياً',
            itemBuilder: (h) => HomeHighlightTile(highlight: h),
          ),

          const SizedBox(height: 70),
        ],
      ],
    );
  }
}

class _SectionGrid<T> extends StatelessWidget {
  final List<T> items;
  final String emptyLabel;
  final Widget Function(T) itemBuilder;

  const _SectionGrid({
    required this.items,
    required this.emptyLabel,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Center(
          child: Text(
            emptyLabel,
            style: GoogleFonts.scheherazadeNew(
              fontSize: 16,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ),
      );
    }
    return ResponsiveGrid<T>(
      padding: EdgeInsets.zero,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      items: items.take(7).toList(),
      itemBuilder: (ctx, item) => itemBuilder(item),
    );
  }
}

class _FirstLaunchEmptyState extends StatelessWidget {
  const _FirstLaunchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.symmetric(vertical: 40),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        decoration: BoxDecoration(
          color: AppColors.surfaceAltDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.midBlue.withAlpha(40), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.midBlue.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.dashboard_customize_rounded,
                color: AppColors.midBlue,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'أهلاً بك في لوحة التحكم',
              style: GoogleFonts.scheherazadeNew(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.appWhite,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم نشر أي كورسات أو امتحانات أو ملاحظات بعد. ابدأ بإنشاء أول محتوى لك باستخدام الأزرار في الأعلى.',
              style: GoogleFonts.scheherazadeNew(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: AppColors.textSecondaryDark,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
