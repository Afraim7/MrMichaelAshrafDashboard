import 'package:equatable/equatable.dart';
import 'package:mrmichaelashrafdashboard/features/students/data/models/user.dart';

class AdminStudentsState extends Equatable {
  const AdminStudentsState();

  @override
  List<Object> get props => [];
}

class StudentsInitial extends AdminStudentsState {}

class StudentsLoading extends AdminStudentsState {}

class StudentsLoaded extends AdminStudentsState {
  final List<AppUser> students;
  const StudentsLoaded(this.students);

  @override
  List<Object> get props => [students];
}

class StudentsError extends AdminStudentsState {
  final String message;
  const StudentsError(this.message);

  @override
  List<Object> get props => [message];
}
