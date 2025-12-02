part of 'admin_functions_cubit.dart';

sealed class AdminFunctionsState extends Equatable {
  const AdminFunctionsState();

  @override
  List<Object> get props => [];
}

// INITIAL STATES
final class AdminFunctionsInitial extends AdminFunctionsState {}

// COURSES STATES
class AdminPublishingCourse extends AdminFunctionsState {}

class AdminCoursePublished extends AdminFunctionsState {}

class AdminDeletingCourse extends AdminFunctionsState {}

class AdminCourseDeleted extends AdminFunctionsState {}

class AdminSavingCourseUpdates extends AdminFunctionsState {}

class AdminCourseUpdatesSaved extends AdminFunctionsState {}

class AdminLoadingCourses extends AdminFunctionsState {}

class AdminCoursesLoaded extends AdminFunctionsState {
  final List<Course> courses;
  const AdminCoursesLoaded({required this.courses});
}

// HIGHLIGHTS STATES
class AdminPublishingHighlight extends AdminFunctionsState {}

class AdminHighlightPublished extends AdminFunctionsState {}

class AdminLoadingHighlights extends AdminFunctionsState {}

class AdminHighlightsLoaded extends AdminFunctionsState {
  final List<Highlight> highlights;
  const AdminHighlightsLoaded({required this.highlights});
}

class AdminDeletingHighlight extends AdminFunctionsState {}

class AdminHighlightDeleted extends AdminFunctionsState {}

class AdminSavingHighlightUpdates extends AdminFunctionsState {}

class AdminHighlightUpdatesSaved extends AdminFunctionsState {}

// EXAMS STATES
class AdminPublishingExam extends AdminFunctionsState {}

class AdminExamPublished extends AdminFunctionsState {}

class AdminSavingExamUpdates extends AdminFunctionsState {}

class AdminExamUpdatesSaved extends AdminFunctionsState {}

class AdminDeletingExam extends AdminFunctionsState {}

class AdminExamDeleted extends AdminFunctionsState {}

class AdminLoadingExams extends AdminFunctionsState {}

class AdminExamsLoaded extends AdminFunctionsState {
  final List<Exam> exams;
  const AdminExamsLoaded({required this.exams});
}

// STUDENTS STATES
class AdminLoadingStudents extends AdminFunctionsState {}

class AdminStudentsLoaded extends AdminFunctionsState {
  final List<AppUser> students;
  const AdminStudentsLoaded({required this.students});
}

// ERROR STATE
class AdminFunctionsError extends AdminFunctionsState {
  final String error;
  const AdminFunctionsError({required this.error});
}
