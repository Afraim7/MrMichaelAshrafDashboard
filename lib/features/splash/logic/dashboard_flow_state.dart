import 'package:equatable/equatable.dart';

sealed class DashboardFlowState extends Equatable {
  const DashboardFlowState();

  @override
  List<Object?> get props => [];
}

class DashboardFlowChecking extends DashboardFlowState {}

class DashboardFlowAdminLogin extends DashboardFlowState {}

class DashboardFlowControlPanel extends DashboardFlowState {}

class DashboardFlowError extends DashboardFlowState {
  final String message;
  const DashboardFlowError(this.message);

  @override
  List<Object?> get props => [message];
}
