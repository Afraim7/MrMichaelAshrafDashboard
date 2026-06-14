import 'package:flutter/material.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class DashboardCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  /// Fires on long-press / right-click. Used by course / exam cards to
  /// trigger a quick action (currently: copy public link). Kept as a plain
  /// VoidCallback now that the popup-menu UI moved into the sheets.
  final VoidCallback? onLongPress;

  final Color shadowColor;
  final Color backgroundColor;
  final Clip clipBehavior;

  const DashboardCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.shadowColor = AppColors.midBlue,
    this.backgroundColor = AppColors.bgDark,
    this.clipBehavior = Clip.none,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        // Right-click / two-finger tap is a natural desktop alias for the
        // long-press shortcut, so we fire the same handler for both.
        onSecondaryTap: widget.onLongPress,
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            clipBehavior: widget.clipBehavior,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.neutral900, width: 1.2),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: widget.shadowColor.withAlpha(50),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
