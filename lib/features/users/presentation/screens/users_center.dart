import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mrmichaelashrafdashboard/core/config/dashboard_configs.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_spacing.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/firebase_error_messages.dart';
import 'package:mrmichaelashrafdashboard/features/users/logic/users_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/users/logic/users_state.dart';
import 'package:mrmichaelashrafdashboard/features/users/presentation/widgets/user_card.dart';
import 'package:mrmichaelashrafdashboard/shared/views/empty_view.dart';
import 'package:mrmichaelashrafdashboard/shared/views/error_view.dart';
import 'package:mrmichaelashrafdashboard/shared/views/loading_view.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/filters.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/pagination_bar.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/responsive_grid.dart';
import 'package:mrmichaelashrafdashboard/features/users/data/models/app_user.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/screen_top_bar.dart';

class UsersCenter extends StatefulWidget {
  const UsersCenter({super.key});

  @override
  State<UsersCenter> createState() => _UsersCenterState();
}

class _UsersCenterState extends State<UsersCenter> {
  Grade _selectedGrade = Grade.allGrades;

  List<AppUser> _pageUsers = const [];
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
      final cubit = context.read<UsersCubit>();
      final results = await Future.wait([
        cubit.fetchUsersPage(
          page: page,
          pageSize: DashboardConfigs.pageSize,
          gradeName: _gradeFilter,
        ),
        if (refetchCount) cubit.getUsersCount(gradeName: _gradeFilter),
      ]);
      if (!mounted) return;
      setState(() {
        _pageUsers = results[0] as List<AppUser>;
        if (refetchCount) _totalCount = results[1] as int;
        _currentPage = page;
        _isPageLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.studentsLoadFailed,
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
      body: BlocListener<UsersCubit, UsersState>(
        listener: (context, state) {
          if (state.errorMessage != null && _pageUsers.isNotEmpty) {
            DashboardHelper.showErrorBar(context, error: state.errorMessage!);
          } else if (state is UpdateUserFieldSuccess) {
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
                title: 'المستخدمين',
                subtitle: 'عرض جميع الطلاب والمستخدمين',
                actions: const [],
              ),

              Filters(
                selectedFilter: _selectedGrade,
                items: Grade.values
                    .map((g) => FilterItem<Grade>(value: g, title: g.label))
                    .toList(),
                onChanged: (selectedValue) {
                  setState(() {
                    _selectedGrade = selectedValue;
                    _pageUsers = const [];
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
    if (_pageError != null && _pageUsers.isEmpty) {
      return Padding(
        padding: AppSpacing.screenBlock,
        child: ErrorView(
          message: _pageError!,
          animationPath: AppAssets.animations.emptyUsersList,
          onRetry: () => _loadPage(_currentPage, refetchCount: true),
        ),
      );
    }
    if (_isPageLoading && _pageUsers.isEmpty) {
      return const LoadingView();
    }
    if (_pageUsers.isEmpty) {
      return EmptyView(
        message: _selectedGrade == Grade.allGrades
            ? AppStrings.emptyStates.noUsers
            : AppStrings.emptyStates.noUsersForGrade,
        animationPath: AppAssets.animations.emptyUsersList,
      );
    }
    return ResponsiveGrid<AppUser>(
      items: _pageUsers,
      itemBuilder: (context, student) => UserCard(student: student),
    );
  }
}
