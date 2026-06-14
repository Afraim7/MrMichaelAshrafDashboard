import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_themes.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/route_generator.dart';
import 'package:mrmichaelashrafdashboard/features/authentication/logic/admin_auth_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/courses_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/dashboard/logic/dashboard_center_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/exams_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/highlights_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/home/logic/home_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/payments/logic/payments_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/platform/logic/platform_status_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/splash/logic/dashboard_flow_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/splash/presentation/splash.dart';
import 'package:mrmichaelashrafdashboard/features/users/logic/users_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: false,
      // Every provider here is lazy (the bloc default): the cubit isn't
      // constructed until something first reads it. Cubit constructors do no
      // I/O, so registering them all at the root costs nothing at startup —
      // the login/splash screens never touch the data cubits, so those stay
      // un-constructed until the dashboard mounts.
      child: MultiBlocProvider(
        providers: [
          // ── Session / platform (needed app-wide, incl. splash & login) ──
          BlocProvider(create: (_) => AdminAuthCubit()),
          BlocProvider(create: (_) => PlatformStatusCubit()),

          // ── UI navigation ──────────────────────────────────────────────
          BlocProvider(create: (_) => DashboardFlowCubit()),
          BlocProvider(create: (_) => DashboardCenterCubit()),

          // ── Feature data cubits ────────────────────────────────────────
          BlocProvider(create: (_) => CoursesCubit()),
          BlocProvider(create: (_) => ExamsCubit()),
          BlocProvider(create: (_) => HighlightsCubit()),
          BlocProvider(create: (_) => UsersCubit()),
          BlocProvider(create: (_) => PaymentsCubit()),

          // ── Home bundle (isolated — owns its own queries) ──────────────
          BlocProvider(create: (_) => HomeCubit()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mr. Michael Ashraf Dashboard',
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supported) {
            return supported.contains(deviceLocale)
                ? deviceLocale
                : const Locale('ar');
          },
          theme: AppThemes.darkTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.dark,
          home: const Splash(),
          onGenerateRoute: RouteGenerator.generateRoutes,
        ),
      ),
    );
  }
}
