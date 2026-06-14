import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PressingEffect extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final Curve curve;
  final bool enable;
  final VoidCallback? onTap;

  const PressingEffect({
    super.key,
    required this.child,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOut,
    this.enable = true,
    this.onTap,
  });

  @override
  State<PressingEffect> createState() => _PressingEffectState();
}

class _PressingEffectState extends State<PressingEffect> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.enable) {
          HapticFeedback.lightImpact();
          setState(() => _pressed = true);
        }
      },
      onTapUp: (_) {
        if (widget.enable) {
          setState(() => _pressed = false);
        }
      },
      onTapCancel: () {
        if (widget.enable) {
          setState(() => _pressed = false);
        }
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: widget.enable && _pressed ? widget.scale : 1.0,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}
