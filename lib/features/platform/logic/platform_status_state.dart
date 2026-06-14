import 'package:equatable/equatable.dart';
import 'package:mrmichaelashrafdashboard/features/platform/data/models/platform_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PlatformStatusCubit state hierarchy. Project-wide pattern.
// ─────────────────────────────────────────────────────────────────────────────

sealed class PlatformStatusState extends Equatable {
  const PlatformStatusState();

  @override
  List<Object?> get props => [];
}

final class PlatformStatusInitial extends PlatformStatusState {
  const PlatformStatusInitial();
}

// ─── loadPlatformConfig ─────────────────────────────────────────────────
final class LoadPlatformConfigLoading extends PlatformStatusState {
  const LoadPlatformConfigLoading();
}

final class LoadPlatformConfigSuccess extends PlatformStatusState {
  final PlatformConfig config;
  const LoadPlatformConfigSuccess(this.config);
  @override
  List<Object?> get props => [config];
}

final class LoadPlatformConfigError extends PlatformStatusState {
  final String message;
  const LoadPlatformConfigError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── toggleMaintenance ──────────────────────────────────────────────────
final class ToggleMaintenanceLoading extends PlatformStatusState {
  const ToggleMaintenanceLoading();
}

final class ToggleMaintenanceSuccess extends PlatformStatusState {
  final PlatformConfig config;
  const ToggleMaintenanceSuccess(this.config);
  @override
  List<Object?> get props => [config];
}

final class ToggleMaintenanceError extends PlatformStatusState {
  final String message;
  const ToggleMaintenanceError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
extension PlatformStatusStateX on PlatformStatusState {
  String? get errorMessage => switch (this) {
        LoadPlatformConfigError(:final message) => message,
        ToggleMaintenanceError(:final message) => message,
        _ => null,
      };
}
