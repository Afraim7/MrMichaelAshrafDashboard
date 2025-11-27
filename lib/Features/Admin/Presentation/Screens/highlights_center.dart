import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_gaps.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/grade.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/sub_button_state.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Logic/Cubits/AdminFunctions/admin_functions_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Presentation/Widgets/admin_highlight_card.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Presentation/Widgets/dashboard_screen_header.dart';
import 'package:mrmichaelashrafdashboard/Shared/Models/highlight.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/app_default_screen.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/grading_filters.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/app_sub_button.dart';

class HighlightsCenter extends StatefulWidget {
  const HighlightsCenter({super.key});

  @override
  State<HighlightsCenter> createState() => _HighlightsCenterState();
}

class _HighlightsCenterState extends State<HighlightsCenter> {
  Grade _selectedGrade = Grade.allGrades;
  List<Highlight> _highlights = [];

  @override
  void initState() {
    super.initState();
    context.read<AdminFunctionsCubit>().fetchAllHighlights();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: BlocConsumer<AdminFunctionsCubit, AdminFunctionsState>(
        listener: (context, state) {
          if (state is AdminHighlightsLoaded) {
            setState(() {
              _highlights = state.highlights;
            });
          } else if (state is AdminFunctionsError) {
            AppHelper.showErrorBar(context, error: state.error);
          }
        },
        builder: (context, state) {
          bool emptyHighlightList = _highlights.isEmpty;
          bool isLoading = state is AdminLoadingHighlights;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: AppHelper.screenWidth > 600
                      ? 20
                      : AppHelper.getDashboardBarTopSpacing(context),
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
                        onTap: () => AppHelper.showHighlightManagerSheet(
                          context: context,
                        ),
                        state: SubButtonState.idle,
                      ),
                    ),
                  ),
                ),

                GradingFilters(
                  onChanged: (selectedValue) {
                    setState(() => _selectedGrade = selectedValue);

                    if (_selectedGrade == Grade.allGrades) {
                      context.read<AdminFunctionsCubit>().fetchAllHighlights();
                    } else {
                      context
                          .read<AdminFunctionsCubit>()
                          .fetchHighlightsByGrade(_selectedGrade.name);
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
                    child: Center(child: AppHelper.appCircularInd),
                  )
                // EMPTY STATE
                else
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: AppDefaultScreen(
                      message: _selectedGrade == Grade.allGrades
                          ? AppStrings.emptyStates.noHighlights
                          : AppStrings.emptyStates.noHighlightsForGrade,
                      animationPath: AppAssets.animations.emptyCoursesList,
                    ),
                  ),

                AppGaps.v20,
              ],
            ),
          );
        },
      ),
    );
  }
}
