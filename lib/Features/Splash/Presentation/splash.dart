import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Logic/Cubits/AdminAuth/admin_auth_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Splash/Logic/app_flow_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Splash/Logic/dashboard_flow_state.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _navigated = false;
  bool _canNavigate = false;
  Timer? _splashTimer;
  VoidCallback? _pendingNavigation;

  void _navigateOnce(VoidCallback action) {
    if (_navigated) return;
    
    if (!_canNavigate) {
      // Store the navigation action to execute after timer completes
      _pendingNavigation = action;
      return;
    }
    
    _navigated = true;
    _splashTimer?.cancel();
    action();
  }

  void _executePendingNavigation() {
    if (_pendingNavigation != null && !_navigated) {
      _navigated = true;
      _pendingNavigation!();
      _pendingNavigation = null;
    }
  }

  @override
  void initState() {
    super.initState();

    // Start 3-second timer
    _splashTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _canNavigate = true;
        });
        // Execute any pending navigation
        _executePendingNavigation();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AdminAuthCubit>().state;

      final isLogged = authState is AdminAuthenticated;
      final isVerified = isLogged ? (authState.admin.emailVerified) : false;

      context.read<DashboardFlowCubit>().checkDashboardFlow(
        isLoggedIn: isLogged,
        isEmailVerified: isVerified,
      );
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: MultiBlocListener(
        listeners: [
          // AUTH LISTENER
          BlocListener<AdminAuthCubit, AdminAuthState>(
            listener: (context, state) {
              final flow = context.read<DashboardFlowCubit>();

              if (state is AdminUnauthenticated) {
                flow.checkDashboardFlow(
                  isLoggedIn: false,
                  isEmailVerified: false,
                );
              }

              if (state is AdminAuthenticated) {
                flow.checkDashboardFlow(
                  isLoggedIn: true,
                  isEmailVerified: state.admin.emailVerified,
                );
              }
            },
          ),

          // FLOW LISTENER
          BlocListener<DashboardFlowCubit, DashboardFlowState>(
            listener: (context, state) {
              if (state is DashboardFlowAdminLogin) {
                _navigateOnce(() {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/admin-login',
                    (_) => false,
                  );
                });
              }

              if (state is DashboardFlowControlPanel) {
                _navigateOnce(() {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/dashboard-home',
                    (_) => false,
                  );
                });
              }

              if (state is DashboardFlowError) {
                AppHelper.showErrorBar(context, error: state.message);
              }
            },
          ),
        ],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Center(child: AppHelper.appLogo)),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: AppHelper.appCircularInd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
