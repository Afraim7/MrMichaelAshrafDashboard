import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_themes.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/route_generator.dart';
import 'package:mrmichaelashrafdashboard/Features/Authentication/Logic/admin_auth_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Logic/admin_functions_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin%20Dashboard/Logic/dashboard_center_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Splash/Logic/dashboard_flow_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Splash/Presentation/splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mrmichaelashrafdashboard/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  runApp(const MyApp());
}

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
          BlocProvider(create: (context) => AdminFunctionsCubit()),
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
