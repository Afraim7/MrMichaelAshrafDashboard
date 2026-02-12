part of 'admin_auth_cubit.dart';

sealed class AdminAuthState extends Equatable {
  const AdminAuthState();

  @override
  List<Object> get props => [];
}

final class AdminAuthInitial extends AdminAuthState {}

class AdminLoading extends AdminAuthState {}

class AdminLoggingIn extends AdminAuthState {}

class AdminLoggingOut extends AdminAuthState {}

class AdminAuthenticated extends AdminAuthState {
  final Admin admin;
  final bool isFreshLogin;

  const AdminAuthenticated({required this.admin, this.isFreshLogin = false});
}

class AdminError extends AdminAuthState {
  final String error;
  const AdminError({required this.error});
}

class AdminUnauthenticated extends AdminAuthState {}
