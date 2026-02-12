import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_themes.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/route_generator.dart';
import 'package:mrmichaelashrafdashboard/features/authentication/logic/admin_auth_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/splash/logic/dashboard_flow_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/splash/presentation/splash.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/admin_courses_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/dashboard/logic/dashboard_center_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/admin_exams_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/admin_highlights_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/students/logic/admin_students_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: false,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AdminAuthCubit()),
          BlocProvider(create: (context) => AdminHighlightsCubit()),
          BlocProvider(create: (context) => AdminCoursesCubit()),
          BlocProvider(create: (context) => AdminExamsCubit()),
          BlocProvider(create: (context) => AdminStudentsCubit()),
          BlocProvider(create: (context) => DashboardFlowCubit()),
          BlocProvider(create: (context) => DashboardCenterCubit()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mr. Michael Ashraf Dashboard',
          locale: Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: [
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
          home: Splash(),
          onGenerateRoute: RouteGenerator.generateRoutes,
        ),
      ),
    );
  }
}
