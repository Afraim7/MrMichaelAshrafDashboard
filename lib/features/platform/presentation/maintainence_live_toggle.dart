import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/platform/logic/platform_status_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/platform/logic/platform_status_state.dart';

class MaintainenceLiveToggle extends StatelessWidget {
  final bool isLive;
  final ValueChanged<bool>? onChanged;
  final DateTime? lastChangedAt;
  final bool isUpdating;

  const MaintainenceLiveToggle({
    super.key,
    required this.isLive,
    this.onChanged,
    this.lastChangedAt,
    this.isUpdating = false,
  });

  Color get _accent => isLive ? AppColors.pastelGreen : AppColors.energyOrange;
  IconData get _icon =>
      isLive ? Icons.public_rounded : Icons.construction_rounded;
  String get _title => isLive ? 'المنصة شغالة' : 'المنصة في وضع الصيانة';
  String get _subtitle => isLive
      ? 'الطلاب يصلون إلى المنصة بشكل طبيعي'
      : 'الطلاب يرون رسالة الصيانة عند الدخول';

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltDark.withAlpha(50),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _accent.withAlpha(60), width: 1),
      ),
      child: Row(
        children: [
          // ── Status glyph
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _accent.withAlpha(28),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon, color: _accent, size: 26),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _title,
                    style: shahr.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle,
                  style: amiri.copyWith(
                    fontSize: 13,
                    color: AppColors.neutral500,
                    height: 1.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Switch — spinner during writes so admins don't tap twice.
          // No confirmation dialog: the toggle flips immediately. Easy to
          // recover from since the same toggle puts it right back.
          if (isUpdating)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation(_accent),
              ),
            )
          else
            Switch.adaptive(
              value: isLive,
              onChanged: onChanged,
              inactiveThumbColor: AppColors.energyOrange,
              inactiveTrackColor: AppColors.energyOrange.withAlpha(60),
            ),
        ],
      ),
    );
  }
}

class MaintainenceLiveToggleStub extends StatefulWidget {
  final bool initialIsLive;
  const MaintainenceLiveToggleStub({super.key, this.initialIsLive = true});

  @override
  State<MaintainenceLiveToggleStub> createState() =>
      _MaintainenceLiveToggleStubState();
}

class _MaintainenceLiveToggleStubState
    extends State<MaintainenceLiveToggleStub> {
  late bool _isLive = widget.initialIsLive;
  DateTime? _lastChangedAt;

  @override
  Widget build(BuildContext context) {
    return MaintainenceLiveToggle(
      isLive: _isLive,
      lastChangedAt: _lastChangedAt,
      onChanged: (next) => setState(() {
        _isLive = next;
        _lastChangedAt = DateTime.now();
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bloc-connected live/maintenance toggle.
//
// Reads the single `app_config/main` doc via [PlatformStatusCubit] and writes
// it back on toggle. Tracks the last-known `isLive` locally so the switch
// keeps its position while a write is in flight (the cubit's loading state
// doesn't carry the config). Errors surface as a snackbar and the switch
// reverts to the real value on the next emitted state.
// ─────────────────────────────────────────────────────────────────────────────

class MaintainenceLiveToggleConnected extends StatefulWidget {
  const MaintainenceLiveToggleConnected({super.key});

  @override
  State<MaintainenceLiveToggleConnected> createState() =>
      _MaintainenceLiveToggleConnectedState();
}

class _MaintainenceLiveToggleConnectedState
    extends State<MaintainenceLiveToggleConnected> {
  /// Last-known live state. Defaults to `true` so the switch ALWAYS renders —
  /// even if the `app_config/main` read is denied/absent. A failed read just
  /// leaves the admin a usable toggle (any subsequent write surfaces its own
  /// error) instead of an eternal spinner.
  bool _isLive = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformStatusCubit, PlatformStatusState>(
      listener: (context, state) {
        if (state is LoadPlatformConfigSuccess) {
          setState(() => _isLive = state.config.isLive);
        } else if (state is ToggleMaintenanceSuccess) {
          setState(() => _isLive = state.config.isLive);
        } else if (state.errorMessage != null) {
          DashboardHelper.showErrorBar(context, error: state.errorMessage!);
        }
      },
      builder: (context, state) {
        // Derive the live flag from the CURRENT state when it carries a config.
        // This widget mounts inside HomeCubit's success branch, which usually
        // resolves AFTER the (much smaller) platform read — so the listener can
        // miss the already-emitted LoadPlatformConfigSuccess. Reading it from
        // `state` here makes the tile correct regardless of mount timing; the
        // local `_isLive` is only a fallback during loading/error/initial.
        final bool isLive = switch (state) {
          LoadPlatformConfigSuccess(:final config) => config.isLive,
          ToggleMaintenanceSuccess(:final config) => config.isLive,
          _ => _isLive,
        };

        // Spin ONLY while a real read/write is in flight — never on error and
        // never on the initial/idle state. This is what kept the tile stuck.
        final isUpdating = state is ToggleMaintenanceLoading ||
            state is LoadPlatformConfigLoading;

        return MaintainenceLiveToggle(
          isLive: isLive,
          isUpdating: isUpdating,
          onChanged: isUpdating
              ? null
              : (next) => context
                  .read<PlatformStatusCubit>()
                  .toggleMaintenance(isLive: next),
        );
      },
    );
  }
}
