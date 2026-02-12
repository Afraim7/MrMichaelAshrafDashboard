import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/sub_button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/admin_highlights_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/admin_highlights_state.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/presentation/widgets/admin_highlight_card.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/presentation/widgets/highlights_analytics_section.dart';
import 'package:mrmichaelashrafdashboard/shared/components/dashboard_screen_header.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_default_screen.dart';
import 'package:mrmichaelashrafdashboard/shared/components/grading_filters.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_sub_button.dart';

class HighlightsCenter extends StatefulWidget {
  const HighlightsCenter({super.key});

  @override
  State<HighlightsCenter> createState() => _HighlightsCenterState();
}

class _HighlightsCenterState extends State<HighlightsCenter> {
  Grade _selectedGrade = Grade.allGrades;
  List<Highlight> _highlights = [];
  Future<void>? _refreshFuture;

  @override
  void initState() {
    super.initState();
    context.read<AdminHighlightsCubit>().fetchAllHighlights();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: BlocConsumer<AdminHighlightsCubit, AdminHighlightsState>(
        listener: (context, state) {
          if (state is HighlightsLoaded) {
            setState(() {
              _highlights = state.highlights;
            });
          } else if (state is HighlightsError) {
            DashboardHelper.showErrorBar(context, error: state.message);
          }
        },
        builder: (context, state) {
          bool emptyHighlightList = _highlights.isEmpty;
          bool isLoading = state is LoadingHighlights;

          return RefreshIndicator(
            backgroundColor: AppColors.cardDark,
            color: AppColors.midBlue,
            onRefresh: () {
              _refreshFuture ??= _refreshHighlights().whenComplete(() {
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

                  // TITLE
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: DashboardScreenHeader(
                      title: 'الملاحظات',
                      describtion:
                          'إدارة وعرض جميع الملاحظات والإعلانات المنشورة في التطبيق',
                    ),
                  ),

                  // ANALYTICS
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: HighlightsAnalyticsSection(highlights: _highlights),
                  ),

                  // PUBLISH NEW HIGHLIGHT BUTTON
                  Align(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 70,
                      ),
                      child: SizedBox(
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
                    ),
                  ),

                  GradingFilters(
                    selectedGrade: _selectedGrade,
                    onChanged: (selectedValue) {
                      setState(() => _selectedGrade = selectedValue);

                      if (selectedValue == Grade.allGrades) {
                        context
                            .read<AdminHighlightsCubit>()
                            .fetchAllHighlights();
                      } else {
                        context
                            .read<AdminHighlightsCubit>()
                            .fetchHighlightsByGrade(selectedValue.name);
                      }
                    },
                  ),

                  // GRID
                  if (!emptyHighlightList)
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
                            itemCount: _highlights.length,
                            itemBuilder: (context, index) {
                              return AdminHighlightCard(
                                highlight: _highlights[index],
                              );
                            },
                          );
                        },
                      ),
                    )
                  // LOADING
                  else if (isLoading)
                    SizedBox(
                      height: 300,
                      child: Center(child: DashboardHelper.appCircularInd),
                    )
                  // EMPTY STATE
                  else
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: AppDefaultScreen(
                        message: _selectedGrade == Grade.allGrades
                            ? AppStrings.emptyStates.noHighlights
                            : AppStrings.emptyStates.noHighlightsForGrade,
                        // Use a highlights-specific empty state animation.
                        animationPath: AppAssets.animations.emptyHighlightList,
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

  // Returns the correct cubit fetch call depending on the grade filter.
  Future<void> _refreshHighlights() {
    final cubit = context.read<AdminHighlightsCubit>();
    if (_selectedGrade == Grade.allGrades) {
      return cubit.fetchAllHighlights();
    }
    return cubit.fetchHighlightsByGrade(_selectedGrade.name);
  }
}
