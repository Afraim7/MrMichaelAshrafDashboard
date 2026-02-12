enum AppThemeMode {
  system,
  light,
  dark,
}

extension AppThemeModeX on AppThemeMode {
  static List<AppThemeMode> getAllThemeModes() => AppThemeMode.values;
}


