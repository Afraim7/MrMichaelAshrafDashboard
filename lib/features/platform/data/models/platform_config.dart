import 'package:mrmichaelashrafdashboard/core/enums/platform_status.dart';

class PlatformConfig {
  final PlatformStatus status;
  final String? message;

  const PlatformConfig({required this.status, this.message});

  bool get isMaintenance => status == PlatformStatus.maintenance;
  bool get isLive => status == PlatformStatus.live;

  factory PlatformConfig.live() =>
      const PlatformConfig(status: PlatformStatus.live);

  factory PlatformConfig.fromMap(Map<String, dynamic> map) {
    return PlatformConfig(
      status: PlatformStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => PlatformStatus.live,
      ),
      message: map['message'] as String?,
    );
  }
}
