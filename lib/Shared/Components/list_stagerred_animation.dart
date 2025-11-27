import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ListStagerredAnimation extends StatefulWidget {
  final Widget child;
  final int index;

  const ListStagerredAnimation({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<ListStagerredAnimation> createState() => _ListStagerredAnimationState();
}

class _ListStagerredAnimationState extends State<ListStagerredAnimation> with SingleTickerProviderStateMixin {
  
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    final curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(curve);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(curve);
  }

  void _startAnimation() {
    if (_hasAnimated || !mounted) return;
    _hasAnimated = true;
    final delayMs = min(widget.index * 40, 800);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key!,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2) {
          _startAnimation();
        }
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
