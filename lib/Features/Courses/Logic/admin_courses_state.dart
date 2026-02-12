import 'package:equatable/equatable.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';

class AdminCoursesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CoursesInitial extends AdminCoursesState {}

class PublishingCourse extends AdminCoursesState {}

class CoursePublished extends AdminCoursesState {}

class DeletingCourse extends AdminCoursesState {}

class CourseDeleted extends AdminCoursesState {}

class SavingCourseUpdates extends AdminCoursesState {}

class CourseUpdatesSaved extends AdminCoursesState {}

class CoursesLoading extends AdminCoursesState {}

class CoursesLoaded extends AdminCoursesState {
  final List<Course> courses;
  CoursesLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class CoursesError extends AdminCoursesState {
  final String message;
  CoursesError(this.message);

  @override
  List<Object?> get props => [message];
}
