import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Basics
  static const Color pureWhite = Colors.white;
  static const Color pureBlack = Colors.black;
  static const Color appWhite = Color.fromRGBO(255, 255, 255, 0.95);
  static const Color appBlack = Color(0XFF090909);
  static const Color neutral50 = Color(0xFFF5F5F5);
  static const Color neutral100 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFCCCCCC);
  static const Color neutral500 = Color(0xFF8E8E8E);
  static const Color neutral600 = Color(0xFF6D6D6D);
  static const Color neutral700 = Color(0xFF4A4A4A);
  static const Color neutral800 = Color(0xFF2B2B2B);
  static const Color neutral900 = Color(0xFF1A1A1A);
  static Color neutra2000 = Colors.white.withOpacity(0.05);

  // Transparent variations
  static const Color appTransperent = Colors.transparent;
  static Color neutralOverlayLow = Colors.white.withOpacity(0.04);
  static Color neutralOverlayMed = Colors.white.withOpacity(0.08);
  static Color neutralOverlayHigh = Colors.white.withOpacity(0.12);

  // Brand Core
  static const Color royalBlue = Color(0xFF2A49D4);
  static const Color midBlue = Color.fromARGB(255, 77, 120, 238);
  static const Color skyBlue = Color.fromARGB(255, 158, 189, 255);
  static const Color appNavy = Color.fromARGB(255, 87, 105, 129);
  static const Color royalYellow = Color(0xFFDAA300);
  static const Color pastelYellow = Color(0xFFFFF5A2);
  static const Color posterRed = Color(0xFFC90114);
  static const Color tomatoRed = Color(0xFFEF4444);
  static const Color pastelGreen = Color.fromARGB(255, 4, 169, 62);
  static const Color lightGreen = Color.fromARGB(255, 70, 201, 113);

  // Light Backgrounds / Surfaces
  static const Color sand50 = Color(0xFFF4EDDB);
  static const Color sand100 = Color(0xFFEFE6D2);
  static const Color surfaceLight = Color(0xFFF7F2E7);
  static const Color surfaceAltLight = Color(0xFFEFE6D2);
  static const Color cardLight = Color(0xFFFBF7EE);
  static const Color strokeHairlineLight = Color(0xFFE6DDCB);

  // Dark Backgrounds / Surfaces
  static const Color bgDark = Color(0xFF0F1113);
  static const Color surfaceDark = Color(0xFF15181B);
  static const Color surfaceAltDark = Color(0xFF1B1E22);
  static const Color cardDark = Color(0xFF20242A);
  static const Color strokeHairlineDark = Color(0xFF2A2F35);
  static const Color textPrimaryDark = Color(0xFFF5F6F7);
  static const Color textSecondaryDark = Color(0xFFC9CDD2);
}
