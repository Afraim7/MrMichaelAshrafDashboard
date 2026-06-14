import 'package:flutter/material.dart';

class TopBarAction {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const TopBarAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });
}
