import 'package:equatable/equatable.dart';

sealed class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

final class UsersInitial extends UsersState {
  const UsersInitial();
}

// ─── updateUserField ─────────────────────────────────────────────────
final class UpdateUserFieldLoading extends UsersState {
  const UpdateUserFieldLoading();
}

final class UpdateUserFieldSuccess extends UsersState {
  final String userId;
  final Map<String, dynamic> updates;
  const UpdateUserFieldSuccess({
    required this.userId,
    required this.updates,
  });
  @override
  List<Object?> get props => [userId, updates];
}

final class UpdateUserFieldError extends UsersState {
  final String message;
  const UpdateUserFieldError(this.message);
  @override
  List<Object?> get props => [message];
}

// NOTE: paginated reads (`fetchUsersPage` / `getUsersCount`) and the
// bulk `fetchUsersBasicInfo` lookup are plain Future-returning helpers on
// the cubit — the center owns its page list + loading/error UI, so they have
// no state triple here. State is reserved for the mutations consumers react to.

// ─── sendEmailVerificationLink ──────────────────────────────────────────
final class SendEmailVerificationLinkLoading extends UsersState {
  const SendEmailVerificationLinkLoading();
}

final class SendEmailVerificationLinkSuccess extends UsersState {
  final String userId;
  const SendEmailVerificationLinkSuccess(this.userId);
  @override
  List<Object?> get props => [userId];
}

final class SendEmailVerificationLinkError extends UsersState {
  final String message;
  const SendEmailVerificationLinkError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
extension UsersStateX on UsersState {
  String? get errorMessage => switch (this) {
    UpdateUserFieldError(:final message) => message,
    SendEmailVerificationLinkError(:final message) => message,
    _ => null,
  };

  bool get isLoading =>
      this is UpdateUserFieldLoading ||
      this is SendEmailVerificationLinkLoading;

  bool get isMutationSuccess =>
      this is UpdateUserFieldSuccess ||
      this is SendEmailVerificationLinkSuccess;
}
