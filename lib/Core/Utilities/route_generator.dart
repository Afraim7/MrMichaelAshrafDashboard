import 'package:flutter/material.dart';
import 'package:mrmichaelashrafdashboard/features/dashboard/presentation/screens/dashboard_home_center.dart';
import 'package:mrmichaelashrafdashboard/features/splash/presentation/splash.dart';
import 'package:mrmichaelashrafdashboard/features/authentication/presentation/screens/admin_login.dart';

class AppRoutes {
  static const splash = '/splash';
  static const adminLogin = '/admin-login';
  static const controlPanel = '/dashboard-home';
}

class RouteGenerator {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const Splash());
      case AppRoutes.adminLogin:
        return MaterialPageRoute(builder: (_) => AdminLogin());
      case AppRoutes.controlPanel:
        return MaterialPageRoute(builder: (_) => DashboardHomeCenter());
      default:
        return MaterialPageRoute(builder: (_) => const Splash());
    }
  }
}
