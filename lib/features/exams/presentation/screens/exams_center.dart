import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mrmichaelashrafdashboard/core/config/dashboard_configs.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/firebase_error_messages.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/exams_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/exams_state.dart';
import 'package:mrmichaelashrafdashboard/features/exams/presentation/widgets/exam_card.dart';
import 'package:mrmichaelashrafdashboard/features/home/data/models/top_bar_action.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/filters.dart';
import 'package:mrmichaelashrafdashboard/shared/views/empty_view.dart';
import 'package:mrmichaelashrafdashboard/shared/views/error_view.dart';
import 'package:mrmichaelashrafdashboard/shared/views/loading_view.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/pagination_bar.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/responsive_grid.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/screen_top_bar.dart';

class ExamsCenter extends StatefulWidget {
  const ExamsCenter({super.key});

  @override
  State<ExamsCenter> createState() => _ExamsCenterState();
}

class _ExamsCenterState extends State<ExamsCenter> {
  Grade _selectedGrade = Grade.allGrades;

  List<Exam> _pageExams = const [];
  Map<String, int> _resultCounts = <String, int>{};
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

  Future<void> _loadPage(int page, {bool refetchCount = false}) async {
    setState(() {
      _isPageLoading = true;
      _pageError = null;
    });
    try {
      final cubit = context.read<ExamsCubit>();
      final results = await Future.wait([
        cubit.fetchExamsPage(
          page: page,
          pageSize: DashboardConfigs.pageSize,
          gradeName: _gradeFilter,
        ),
        if (refetchCount) cubit.getExamsCount(gradeName: _gradeFilter),
      ]);
      if (!mounted) return;
      final exams = results[0] as List<Exam>;

      // Fan out one COUNT query per exam in parallel — cheap (~1 doc read
      // each) and surfaces the "students finished" badge on every card.
      final counts = await Future.wait(
        exams.map((e) => cubit.fetchExamResultsCount(e.examID)),
      );
      if (!mounted) return;

      setState(() {
        _pageExams = exams;
        _resultCounts = <String, int>{
          for (var i = 0; i < exams.length; i++) exams[i].examID: counts[i],
        };
        if (refetchCount) _totalCount = results[1] as int;
        _currentPage = page;
        _isPageLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.examLoadFailedAdmin,
      );
      setState(() {
        _isPageLoading = false;
        _pageError = translated.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: BlocListener<ExamsCubit, ExamsState>(
        listener: (context, state) {
          if (state.errorMessage != null && _pageExams.isNotEmpty) {
            DashboardHelper.showErrorBar(context, error: state.errorMessage!);
          } else if (state is DeleteExamSuccess ||
              state is PublishExamSuccess ||
              state is SaveExamUpdatesSuccess ||
              state is ToggleExamVisibilitySuccess) {
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
                title: 'الامتحانات',
                subtitle: 'إدارة وعرض جميع الامتحانات المتاحة في التطبيق',
                actions: [
                  TopBarAction(
                    label: 'إضافة امتحان جديد',
                    onPressed: () =>
                        DashboardHelper.showExamsManager(context: context),
                    isPrimary: true,
                  ),
                ],
              ),

              Filters(
                selectedFilter: _selectedGrade,
                items: Grade.values
                    .map((g) => FilterItem<Grade>(value: g, title: g.label))
                    .toList(),
                onChanged: (selectedValue) {
                  setState(() {
                    _selectedGrade = selectedValue;
                    _pageExams = const [];
                    _currentPage = 1;
                    // Flip into loading inside the same setState so the body
                    // doesn't flash EmptyView for a frame before _loadPage's
                    // own setState lands.
                    _isPageLoading = true;
                    _pageError = null;
                  });
                  _loadPage(1, refetchCount: true);
                },
              ),

              _buildBody(),

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
    if (_pageError != null && _pageExams.isEmpty) {
      return ErrorView(
        message: _pageError!,
        animationPath: AppAssets.animations.emptyExamsList,
        onRetry: () => _loadPage(_currentPage, refetchCount: true),
      );
    }
    if (_isPageLoading && _pageExams.isEmpty) {
      return const LoadingView();
    }
    if (_pageExams.isEmpty) {
      return EmptyView(
        message: _selectedGrade == Grade.allGrades
            ? AppStrings.emptyStates.noPublishedExams
            : AppStrings.emptyStates.noExamsForGrade,
        animationPath: AppAssets.animations.emptyExamsList,
      );
    }
    return ResponsiveGrid<Exam>(
      items: _pageExams,
      itemBuilder: (context, exam) => ExamCard(
        examId: exam.examID,
        isVisible: exam.isVisible,
        examTitle: exam.title,
        examDescribtion: exam.description ?? '',
        grade: exam.grade.label,
        isExamActive: exam.isActive(),
        examState: exam.state ?? exam.computeUserExamState(),
        duration: exam.duration,
        questionsCount: exam.questions?.length,
        examFullMark: (exam.questions == null || exam.questions!.isEmpty)
            ? null
            : exam.fullExamMark().toInt(),
        examDateRange: exam.examDateRange(exam.startTime, exam.endTime),
        finishedUsersCount: _resultCounts[exam.examID] ?? 0,
        onViewResults: () async {
          await DashboardHelper.showExamResultsSheet(
            context: context,
            exam: exam,
          );
        },
        onViewExamManager: () => DashboardHelper.showExamsManager(
          context: context,
          existingExam: exam,
        ),
        onLongPress: () => _copyExamLink(exam),
      ),
    );
  }

  /// Copies the public exam URL to the clipboard and toasts on success.
  Future<void> _copyExamLink(Exam exam) async {
    final url = DashboardConfigs.publicExamUrl(exam.examID);
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    DashboardHelper.showSuccessBar(
      context,
      message: 'تم نسخ رابط الامتحان إلى الحافظة',
    );
  }
}
