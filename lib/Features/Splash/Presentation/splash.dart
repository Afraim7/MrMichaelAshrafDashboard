import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/Features/Authentication/Logic/admin_auth_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Splash/Logic/dashboard_flow_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Splash/Logic/dashboard_flow_state.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // Caches the latest auth state so we only route once the cubit is ready.
  AdminAuthState? _latestAuthState;

  @override
  void initState() {
    super.initState();
    _latestAuthState = context.read<AdminAuthCubit>().state;
    WidgetsBinding.instance.addPostFrameCallback((_) => _runFlowCheck());
  }

  void _runFlowCheck() {
    final authState = _latestAuthState ?? context.read<AdminAuthCubit>().state;

    // Skip routing while the auth cubit is still determining the user state.
    if (authState is AdminAuthInitial ||
        authState is AdminLoggingIn ||
        authState is AdminLoggingOut ||
        authState is AdminLoading) {
      return;
    }

    final isLoggedIn = authState is AdminAuthenticated;
    final isVerified = isLoggedIn ? authState.admin.emailVerified : false;

    context.read<DashboardFlowCubit>().checkDashboardFlow(
          isLoggedIn: isLoggedIn,
          isEmailVerified: isVerified,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: MultiBlocListener(
        listeners: [
          BlocListener<AdminAuthCubit, AdminAuthState>(
            listener: (context, authState) {
              _latestAuthState = authState;

              if (authState is AdminAuthenticated ||
                  authState is AdminUnauthenticated ||
                  authState is AdminError) {
                _runFlowCheck();
              }
            },
          ),
          BlocListener<DashboardFlowCubit, DashboardFlowState>(
            listener: (context, state) {
              if (state is DashboardFlowAdminLogin) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/admin-login',
                  (_) => false,
                );
              }

              if (state is DashboardFlowControlPanel) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/dashboard-home',
                  (_) => false,
                );
              }

              if (state is DashboardFlowError) {
                DashboardHelper.showErrorBar(context, error: state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<DashboardFlowCubit, DashboardFlowState>(
          builder: (context, state) {
            final bool isError = state is DashboardFlowError;

            Widget loader;

            if (state is DashboardFlowChecking) {
              loader = DashboardHelper.appCircularInd;
            } else if (isError) {
              loader = Column(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: Lottie.asset(
                      AppAssets.animations.redWarning,
                      repeat: false,
                    ),
                  ),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: _runFlowCheck,
                    child: Text(
                      "المحاولة مرة أخرى",
                      style: GoogleFonts.scheherazadeNew(
                        color: AppColors.neutral100,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 2,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              loader = const SizedBox.shrink();
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Center(child: DashboardHelper.appLogo)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: loader,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
