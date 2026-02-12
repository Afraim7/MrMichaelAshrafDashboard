import 'package:equatable/equatable.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';

class AdminExamsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExamsInitial extends AdminExamsState {}

class ExamsLoading extends AdminExamsState {}

class PublishingExam extends AdminExamsState {}

class ExamPublished extends AdminExamsState {}

class SavingExamUpdates extends AdminExamsState {}

class ExamUpdatesSaved extends AdminExamsState {}

class DeletingExam extends AdminExamsState {}

class ExamDeleted extends AdminExamsState {}

class LoadingExams extends AdminExamsState {}

class ExamsLoaded extends AdminExamsState {
  final List<Exam> exams;
  ExamsLoaded({required this.exams});

  @override
  List<Object?> get props => [exams];
}

class ExamsError extends AdminExamsState {
  final String message;
  ExamsError({required this.message});

  @override
  List<Object?> get props => [message];
}
