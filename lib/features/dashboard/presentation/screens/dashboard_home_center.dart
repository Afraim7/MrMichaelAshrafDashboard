import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_spacing.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/route_generator.dart';
import 'package:mrmichaelashrafdashboard/features/authentication/logic/admin_auth_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/authentication/presentation/widgets/admin_profile_drawer.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/courses_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/courses_state.dart';
import 'package:mrmichaelashrafdashboard/features/dashboard/logic/dashboard_center_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/dashboard/presentation/widgets/dashboard_bar.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/exams_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/exams_state.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/highlights_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/highlights_state.dart';
import 'package:mrmichaelashrafdashboard/features/home/logic/home_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/home/presentation/screens/home.dart';
import 'package:mrmichaelashrafdashboard/features/courses/presentation/screens/courses_center.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/presentation/screens/highlights_center.dart';
import 'package:mrmichaelashrafdashboard/features/exams/presentation/screens/exams_center.dart';
import 'package:mrmichaelashrafdashboard/features/payments/presentation/screens/payments_center.dart';
import 'package:mrmichaelashrafdashboard/features/users/presentation/screens/users_center.dart';

class DashboardHomeCenter extends StatelessWidget {
  const DashboardHomeCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 600;
    return MultiBlocListener(
      listeners: [
        // ── Auth — drives post-logout navigation ─────────────────────────
        BlocListener<AdminAuthCubit, AdminAuthState>(
          listener: (context, state) {
            if (state is SignOutSuccess ||
                state is CheckAuthStatusUnauthenticated) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.adminLogin, (_) => false);
            } else if (state is SignOutError) {
              DashboardHelper.showErrorBar(context, error: state.message);
            }
          },
        ),

        // ── Cross-center refresh ─────────────────────────────────────────
        // Every center is alive in the IndexedStack, but each one only
        // listens to its OWN cubit. Without this layer, publishing a course
        // in CoursesCenter wouldn't refresh the Home preview's top-courses /
        // counters — the admin would have to pull-to-refresh the home tab.
        //
        // Listening here keeps that aggregation problem contained: each
        // success kicks `HomeCubit.refresh()`, which silently re-fetches
        // the home bundle and emits a Refresh→Success pair (the home keeps
        // the previous bundle on screen during the refresh, so there's no
        // skeleton flash).
        BlocListener<CoursesCubit, CoursesState>(
          listenWhen: (_, s) =>
              s is PublishCourseSuccess ||
              s is SaveCourseUpdatesSuccess ||
              s is DeleteCourseSuccess ||
              s is ToggleCourseVisibilitySuccess,
          listener: (context, _) => context.read<HomeCubit>().refresh(),
        ),
        BlocListener<ExamsCubit, ExamsState>(
          listenWhen: (_, s) =>
              s is PublishExamSuccess ||
              s is SaveExamUpdatesSuccess ||
              s is DeleteExamSuccess ||
              s is ToggleExamVisibilitySuccess,
          listener: (context, _) => context.read<HomeCubit>().refresh(),
        ),
        BlocListener<HighlightsCubit, HighlightsState>(
          listenWhen: (_, s) =>
              s is PublishHighlightSuccess ||
              s is SaveHighlightUpdatesSuccess ||
              s is DeleteHighlightSuccess ||
              s is ToggleHighlightVisibilitySuccess,
          listener: (context, _) => context.read<HomeCubit>().refresh(),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.appBlack,
        endDrawer: BlocProvider.value(
          value: context.read<AdminAuthCubit>(),
          child: AdminProfileDrawer(
            admin:
                context.read<AdminAuthCubit>().state
                    is CheckAuthStatusAuthenticated
                ? (context.read<AdminAuthCubit>().state
                          as CheckAuthStatusAuthenticated)
                      .admin
                : null,
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: AppSpacing.screenSafe(isDesktop: isDesktop),
                child: BlocBuilder<DashboardCenterCubit, int>(
                  builder: (context, currentIndex) {
                    return IndexedStack(
                      index: currentIndex,
                      children: const [
                        ControlPanel(),
                        CoursesCenter(),
                        ExamsCenter(),
                        HighlightsCenter(),
                        PaymentsCenter(),
                        UsersCenter(),
                      ],
                    );
                  },
                ),
              ),
            ),

            Align(
              alignment: isDesktop
                  ? Alignment.centerRight
                  : Alignment.topCenter,
              child: isDesktop
                  ? const DashboardBar()
                  : const SafeArea(child: DashboardBar()),
            ),
          ],
        ),
      ),
    );
  }
}
