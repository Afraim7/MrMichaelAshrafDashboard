class DashboardConfigs {
  DashboardConfigs._();

  // ─── Pagination ────────────────────────────────────────────────────────
  static const int pageSize = 25;

  static const String publicHost = 'https://mrmichaelashraf-a6c17.web.app';

  static String publicCourseUrl(String courseId) =>
      '$publicHost/course/$courseId';

  static String publicExamUrl(String examId) => '$publicHost/exam/$examId';
}
