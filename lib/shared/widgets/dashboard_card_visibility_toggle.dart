import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class DashboardCardVisibilityToggleStub extends StatefulWidget {
  final bool initialIsVisible;
  final bool compact;

  const DashboardCardVisibilityToggleStub({
    super.key,
    this.initialIsVisible = true,
    this.compact = true,
  });

  @override
  State<DashboardCardVisibilityToggleStub> createState() =>
      _DashboardCardVisibilityToggleStubState();
}

class _DashboardCardVisibilityToggleStubState
    extends State<DashboardCardVisibilityToggleStub> {
  late bool _isVisible = widget.initialIsVisible;

  @override
  Widget build(BuildContext context) {
    return DashboardCardVisibilityToggle(
      isVisible: _isVisible,
      compact: widget.compact,
      onChanged: (next) => setState(() => _isVisible = next),
    );
  }
}

class DashboardCardVisibilityToggle extends StatelessWidget {
  final bool isVisible;
  final ValueChanged<bool>? onChanged;
  final bool compact;

  final bool isUpdating;

  /// Label override for the visible state. Default: "ظاهر".
  final String visibleLabel;

  /// Label override for the hidden state. Default: "مخفي".
  final String hiddenLabel;

  const DashboardCardVisibilityToggle({
    super.key,
    required this.isVisible,
    this.onChanged,
    this.compact = false,
    this.isUpdating = false,
    this.visibleLabel = 'ظاهر',
    this.hiddenLabel = 'مخفي',
  });

  @override
  Widget build(BuildContext context) {
    final accent = isVisible ? AppColors.pastelGreen : AppColors.neutral500;
    final disabled = onChanged == null || isUpdating;
    final glyph = isVisible
        ? Icons.visibility_rounded
        : Icons.visibility_off_rounded;
    final tooltip = isVisible
        ? 'المحتوي ظاهر للطلاب — اضغط لإخفائه'
        : 'المحتوي مخفي عن الطلاب — اضغط لإظهاره';

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : () => onChanged!(!isVisible),
          borderRadius: BorderRadius.circular(compact ? 12 : 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: compact
                ? const EdgeInsets.all(7)
                : const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withAlpha(25),
              borderRadius: BorderRadius.circular(compact ? 12 : 18),
              border: Border.all(color: accent.withAlpha(60), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUpdating)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  )
                else
                  Icon(glyph, color: accent, size: 14),
                if (!compact) ...[
                  const SizedBox(width: 6),
                  Text(
                    isVisible ? visibleLabel : hiddenLabel,
                    style: GoogleFonts.amiri(
                      fontSize: 12,
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
