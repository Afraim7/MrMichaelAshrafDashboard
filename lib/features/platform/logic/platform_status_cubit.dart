import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/core/enums/platform_status.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/firebase_error_messages.dart';
import 'package:mrmichaelashrafdashboard/features/platform/data/models/platform_config.dart';
import 'package:mrmichaelashrafdashboard/features/platform/logic/platform_status_state.dart';

/// Owns the single `app_configs/platform` document — the platform-wide
/// live ↔ maintenance switch the admin flips from the home screen.
///
/// One doc, two actions: read it once on home open, write it on toggle. The
/// student app reads the same doc to decide whether to show the maintenance
/// screen.
class PlatformStatusCubit extends Cubit<PlatformStatusState> {
  PlatformStatusCubit() : super(const PlatformStatusInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _configRef =>
      _firestore.collection('app_configs').doc('platform');

  // ─── loadPlatformConfig ─────────────────────────────────────────────────
  /// Reads `app_config/main`. When the doc doesn't exist yet, defaults to a
  /// live platform so a fresh project isn't stuck in maintenance.
  Future<void> loadPlatformConfig() async {
    emit(const LoadPlatformConfigLoading());
    try {
      final snap = await _configRef.get();
      final config = (snap.exists && snap.data() != null)
          ? PlatformConfig.fromMap(snap.data()!)
          : PlatformConfig.live();
      emit(LoadPlatformConfigSuccess(config));
    } catch (e) {
      emit(LoadPlatformConfigError(
        FirebaseErrorTranslator.translate(
          e,
          fallback: 'تعذّر تحميل حالة المنصة، حاول مجددًا',
        ).message,
      ));
    }
  }

  // ─── toggleMaintenance ──────────────────────────────────────────────────
  /// Flips the platform between live and maintenance. [isLive] is the desired
  /// new value (true = live, false = maintenance). Merge-writes so any other
  /// config fields (message, version…) are preserved.
  Future<void> toggleMaintenance({required bool isLive}) async {
    emit(const ToggleMaintenanceLoading());
    try {
      final status = isLive ? PlatformStatus.live : PlatformStatus.maintenance;
      await _configRef.set({'status': status.name}, SetOptions(merge: true));
      emit(ToggleMaintenanceSuccess(PlatformConfig(status: status)));
    } catch (e) {
      emit(ToggleMaintenanceError(
        FirebaseErrorTranslator.translate(
          e,
          fallback: 'تعذّر تغيير حالة المنصة، حاول مجددًا',
        ).message,
      ));
    }
  }
}
