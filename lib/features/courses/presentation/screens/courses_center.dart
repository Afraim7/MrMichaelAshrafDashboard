import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mrmichaelashrafdashboard/core/config/dashboard_configs.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_spacing.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/firebase_error_messages.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/courses_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/courses_state.dart';
import 'package:mrmichaelashrafdashboard/features/courses/presentation/widgets/course_card.dart';
import 'package:mrmichaelashrafdashboard/features/home/data/models/top_bar_action.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/filters.dart';
import 'package:mrmichaelashrafdashboard/shared/views/empty_view.dart';
import 'package:mrmichaelashrafdashboard/shared/views/error_view.dart';
import 'package:mrmichaelashrafdashboard/shared/views/loading_view.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/pagination_bar.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/responsive_grid.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/screen_top_bar.dart';

class CoursesCenter extends StatefulWidget {
  const CoursesCenter({super.key});

  @override
  State<CoursesCenter> createState() => _CoursesCenterState();
}

class _CoursesCenterState extends State<CoursesCenter> {
  Grade _selectedGrade = Grade.allGrades;

  // ─── Local pagination state ─────────────────────────────────────────────
  // Owned by the screen (not the cubit) so the same cubit stays free to
  // serve the home screen's "top 7 courses" feed without page semantics.
  List<Course> _pageCourses = const [];
  int _currentPage = 1;
  int _totalCount = 0;
  bool _isPageLoading = true;
  String? _pageError;

  @override
  void initState() {
    super.initState();
    _loadPage(1, refetchCount: true);
  }

  String? get _gradeFilter =>
      _selectedGrade == Grade.allGrades ? null : _selectedGrade.name;

  // ─── Loaders ────────────────────────────────────────────────────────────

  /// Single entry point for fetching a page. When [refetchCount] is true the
  /// total is re-pulled too — used on first load and whenever the filter
  /// changes, since the chip count depends on it.
  Future<void> _loadPage(int page, {bool refetchCount = false}) async {
    setState(() {
      _isPageLoading = true;
      _pageError = null;
    });
    try {
      final cubit = context.read<CoursesCubit>();
      final results = await Future.wait([
        cubit.fetchCoursesPage(
          page: page,
          pageSize: DashboardConfigs.pageSize,
          gradeName: _gradeFilter,
        ),
        if (refetchCount) cubit.getCoursesCount(gradeName: _gradeFilter),
      ]);
      if (!mounted) return;
      setState(() {
        _pageCourses = results[0] as List<Course>;
        if (refetchCount) _totalCount = results[1] as int;
        _currentPage = page;
        _isPageLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.courseLoadFailed,
      );
      setState(() {
        _isPageLoading = false;
        _pageError = translated.message;
      });
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: BlocListener<CoursesCubit, CoursesState>(
        // Pagination owns its own data path, but cubit-driven side effects
        // (delete / publish / save) still need to refresh the visible page
        // and surface their errors via the toast.
        listener: (context, state) {
          if (state.errorMessage != null && _pageCourses.isNotEmpty) {
            DashboardHelper.showErrorBar(context, error: state.errorMessage!);
          } else if (state is DeleteCourseSuccess ||
              state is PublishCourseSuccess ||
              state is SaveCourseUpdatesSuccess ||
              state is ToggleCourseVisibilitySuccess) {
            _loadPage(_currentPage, refetchCount: true);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenTopBar(
                title: 'الكورسات',
                subtitle: 'إدارة وعرض جميع الكورسات المتاحة في التطبيق',
                actions: [
                  TopBarAction(
                    label: 'إضافة كورس جديد',
                    onPressed: () =>
                        DashboardHelper.showCoursesManager(context: context),
                    isPrimary: true,
                  ),
                ],
              ),

              // FILTERS
              Filters(
                selectedFilter: _selectedGrade,
                items: Grade.values
                    .map((g) => FilterItem<Grade>(value: g, title: g.label))
                    .toList(),
                onChanged: (selectedValue) {
                  setState(() {
                    _selectedGrade = selectedValue;
                    _pageCourses = const [];
                    _currentPage = 1;
                    // Mark loading inside the same setState that clears the
                    // list, so _buildBody's "loading + empty → LoadingView"
                    // condition is true on the very next frame. Without this
                    // there's a one-frame window where the list is empty but
                    // loading is still false — body falls through to
                    // EmptyView and the spinner appears late.
                    _isPageLoading = true;
                    _pageError = null;
                  });
                  _loadPage(1, refetchCount: true);
                },
              ),

              _buildBody(),

              // Pagination bar — hidden by itself when totalCount fits in a
              // single page; otherwise pinned to the bottom of the section.
              PaginationBar(
                currentPage: _currentPage,
                totalItems: _totalCount,
                pageSize: DashboardConfigs.pageSize,
                isLoading: _isPageLoading,
                onPageChange: (p) => _loadPage(p),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_pageError != null && _pageCourses.isEmpty) {
      return Padding(
        padding: AppSpacing.screenBlock,
        child: ErrorView(
          message: _pageError!,
          animationPath: AppAssets.animations.emptyCoursesList,
          onRetry: () => _loadPage(_currentPage, refetchCount: true),
        ),
      );
    }
    if (_isPageLoading && _pageCourses.isEmpty) {
      return const LoadingView();
    }
    if (_pageCourses.isEmpty) {
      return Padding(
        padding: AppSpacing.screenBlock,
        child: EmptyView(
          message: _selectedGrade == Grade.allGrades
              ? AppStrings.emptyStates.noPublishedCourses
              : AppStrings.emptyStates.noCoursesForGrade,
          animationPath: AppAssets.animations.emptyCoursesList,
        ),
      );
    }
    return ResponsiveGrid<Course>(
      items: _pageCourses,
      itemBuilder: (context, course) => CourseCard(
        courseId: course.courseID,
        isVisible: course.isVisible,
        title: course.title,
        describtion: course.description,
        numberOfLessons: course.lessons.length,
        grade: course.grade.label,
        studentsCount: course.enrollmentCount,
        price: course.price,
        imageUrl: course.background,
        onTap: () => DashboardHelper.showCoursesManager(
          context: context,
          existingCourse: course,
        ),
        onLongPress: () => _copyCourseLink(course),
        onViewEnrollments: () async {
          await DashboardHelper.showCourseEnrollmentsSheet(
            context: context,
            course: course,
          );
          if (mounted) _loadPage(_currentPage, refetchCount: true);
        },
      ),
    );
  }

  Future<void> _copyCourseLink(Course course) async {
    final url = DashboardConfigs.publicCourseUrl(course.courseID);
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    DashboardHelper.showSuccessBar(
      context,
      message: 'تم نسخ رابط الكورس إلى الحافظة',
    );
  }
}
