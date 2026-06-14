import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mrmichaelashrafdashboard/core/config/dashboard_configs.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/firebase_error_messages.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/highlights_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/highlights_state.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/presentation/widgets/highlight_card.dart';
import 'package:mrmichaelashrafdashboard/features/home/data/models/top_bar_action.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';
import 'package:mrmichaelashrafdashboard/shared/views/empty_view.dart';
import 'package:mrmichaelashrafdashboard/shared/views/error_view.dart';
import 'package:mrmichaelashrafdashboard/shared/views/loading_view.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/filters.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/pagination_bar.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/responsive_grid.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/screen_top_bar.dart';

class HighlightsCenter extends StatefulWidget {
  const HighlightsCenter({super.key});

  @override
  State<HighlightsCenter> createState() => _HighlightsCenterState();
}

class _HighlightsCenterState extends State<HighlightsCenter> {
  Grade _selectedGrade = Grade.allGrades;

  List<Highlight> _pageHighlights = const [];
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
      final cubit = context.read<HighlightsCubit>();
      final results = await Future.wait([
        cubit.fetchHighlightsPage(
          page: page,
          pageSize: DashboardConfigs.pageSize,
          gradeName: _gradeFilter,
        ),
        if (refetchCount) cubit.getHighlightsCount(gradeName: _gradeFilter),
      ]);
      if (!mounted) return;
      setState(() {
        _pageHighlights = results[0] as List<Highlight>;
        if (refetchCount) _totalCount = results[1] as int;
        _currentPage = page;
        _isPageLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.notesLoadFailed,
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
      body: BlocListener<HighlightsCubit, HighlightsState>(
        listener: (context, state) {
          if (state.errorMessage != null && _pageHighlights.isNotEmpty) {
            DashboardHelper.showErrorBar(context, error: state.errorMessage!);
          } else if (state is DeleteHighlightSuccess ||
              state is PublishHighlightSuccess ||
              state is SaveHighlightUpdatesSuccess ||
              state is ToggleHighlightVisibilitySuccess) {
            // Re-fetch so the grid reflects the new visibility / content.
            // Delete shrinks the count → refetch it; visibility toggle keeps
            // the count, so only the page slice needs refreshing, but
            // refetching the count is cheap and keeps one code path.
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
                title: 'الملاحظات',
                subtitle:
                    'إدارة وعرض جميع الملاحظات والإعلانات المنشورة في التطبيق',
                actions: [
                  TopBarAction(
                    label: 'إضافة ملاحظة جديدة',
                    onPressed: () => DashboardHelper.showHighlightManagerSheet(
                      context: context,
                    ),
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
                    _pageHighlights = const [];
                    _currentPage = 1;
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
    if (_pageError != null && _pageHighlights.isEmpty) {
      return ErrorView(
        message: _pageError!,
        animationPath: AppAssets.animations.emptyHighlightList,
        onRetry: () => _loadPage(_currentPage, refetchCount: true),
      );
    }
    if (_isPageLoading && _pageHighlights.isEmpty) {
      return const LoadingView();
    }
    if (_pageHighlights.isEmpty) {
      return EmptyView(
        message: _selectedGrade == Grade.allGrades
            ? AppStrings.emptyStates.noHighlights
            : AppStrings.emptyStates.noHighlightsForGrade,
        animationPath: AppAssets.animations.emptyHighlightList,
      );
    }
    return ResponsiveGrid<Highlight>(
      items: _pageHighlights,
      itemBuilder: (context, h) => HighlightCard(highlight: h),
    );
  }
}
