part of 'admin_auth_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminAuthCubit state hierarchy.
//
// Convention used across every cubit in this project:
//
//   * Sealed base class with `props == []`.
//   * One initial state, suffixed `Initial`.
//   * Every async action OWNS three dedicated states, named after itself:
//       <Action>Loading        — fires before the work starts.
//       <Action>Success(...)   — carries the relevant result data, if any.
//       <Action>Error(message) — carries a user-displayable Arabic message.
//
//   * Error states ALWAYS carry a `message`.
//   * Success states carry data fields when the action produces a meaningful
//     value (e.g. fetched entity); they're empty otherwise.
//   * NO generic `Loading` / `Success` / `Error` shared across actions.
//
// `checkAuthStatus` is the one action that has two distinct success branches
// — *Authenticated* and *Unauthenticated* — because the routing layer treats
// them as the two terminal outcomes of the same "who is signed in?" question.
// ─────────────────────────────────────────────────────────────────────────────

sealed class AdminAuthState extends Equatable {
  const AdminAuthState();

  @override
  List<Object?> get props => [];
}

final class AdminAuthInitial extends AdminAuthState {
  const AdminAuthInitial();
}

// ─── signIn ─────────────────────────────────────────────────────────────
final class SignInLoading extends AdminAuthState {
  const SignInLoading();
}

final class SignInSuccess extends AdminAuthState {
  final Admin admin;
  const SignInSuccess(this.admin);
  @override
  List<Object?> get props => [admin];
}

final class SignInError extends AdminAuthState {
  final String message;
  const SignInError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── signOut ────────────────────────────────────────────────────────────
final class SignOutLoading extends AdminAuthState {
  const SignOutLoading();
}

final class SignOutSuccess extends AdminAuthState {
  const SignOutSuccess();
}

final class SignOutError extends AdminAuthState {
  final String message;
  const SignOutError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── sendPasswordReset ──────────────────────────────────────────────────
final class SendPasswordResetLoading extends AdminAuthState {
  const SendPasswordResetLoading();
}

final class SendPasswordResetSuccess extends AdminAuthState {
  const SendPasswordResetSuccess();
}

final class SendPasswordResetError extends AdminAuthState {
  final String message;
  const SendPasswordResetError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── changePassword ─────────────────────────────────────────────────────
final class ChangePasswordLoading extends AdminAuthState {
  const ChangePasswordLoading();
}

final class ChangePasswordSuccess extends AdminAuthState {
  const ChangePasswordSuccess();
}

final class ChangePasswordError extends AdminAuthState {
  final String message;
  const ChangePasswordError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── updateAdminProfile ─────────────────────────────────────────────────
final class UpdateAdminProfileLoading extends AdminAuthState {
  const UpdateAdminProfileLoading();
}

final class UpdateAdminProfileSuccess extends AdminAuthState {
  final Admin admin;
  const UpdateAdminProfileSuccess(this.admin);
  @override
  List<Object?> get props => [admin];
}

final class UpdateAdminProfileError extends AdminAuthState {
  final String message;
  const UpdateAdminProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── checkAuthStatus ────────────────────────────────────────────────────
// Driven by `FirebaseAuth.authStateChanges()` — emits whenever the signed-in
// user changes. The two terminal success branches (Authenticated vs
// Unauthenticated) are what the splash flow listens for to decide routing.
final class CheckAuthStatusLoading extends AdminAuthState {
  const CheckAuthStatusLoading();
}

final class CheckAuthStatusAuthenticated extends AdminAuthState {
  final Admin admin;

  /// True only on the first emission after a successful `signIn` call so the
  /// login screen can route exactly once instead of every auth-state tick.
  final bool isFreshLogin;

  const CheckAuthStatusAuthenticated({
    required this.admin,
    this.isFreshLogin = false,
  });

  @override
  List<Object?> get props => [admin, isFreshLogin];
}

final class CheckAuthStatusUnauthenticated extends AdminAuthState {
  const CheckAuthStatusUnauthenticated();
}

final class CheckAuthStatusError extends AdminAuthState {
  final String message;
  const CheckAuthStatusError(this.message);
  @override
  List<Object?> get props => [message];
}
