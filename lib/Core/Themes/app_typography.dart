import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';

class AppTypography {
  AppTypography._();

  // ===== HELPER METHODS =====
  static TextStyle _noto({
    required double size,
    required FontWeight weight,
    required Color color,
    double letterSpacing = 0.0,
    double height = 1.4,
    FontStyle fontStyle = FontStyle.normal,
    double wordSpacing = 0.0,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.scheherazadeNew(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: fontStyle,
      wordSpacing: wordSpacing,
      decoration: decoration,
    );
  }

  static TextStyle _amiri({
    required double size,
    required FontWeight weight,
    required Color color,
    double letterSpacing = 0.0,
    double height = 1.4,
    FontStyle fontStyle = FontStyle.normal,
    double wordSpacing = 0.0,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.amiri(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: fontStyle,
      wordSpacing: wordSpacing,
      decoration: decoration,
    );
  }

  static TextStyle _poppins({
    required double size,
    required FontWeight weight,
    required Color color,
    double letterSpacing = 0.0,
    double height = 1.4,
    FontStyle fontStyle = FontStyle.normal,
    double wordSpacing = 0.0,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: fontStyle,
      wordSpacing: wordSpacing,
      decoration: decoration,
    );
  }

  // ===== DISPLAY TYPOGRAPHY (Large Headlines) =====
  static TextStyle displayLarge(Color color) => _amiri(
    size: 48.sp,
    weight: FontWeight.w700,
    color: color,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium(Color color) => _amiri(
    size: 40.sp,
    weight: FontWeight.w600,
    color: color,
    height: 1.15,
    letterSpacing: -0.25,
  );

  static TextStyle displaySmall(Color color) =>
      _amiri(size: 32.sp, weight: FontWeight.w600, color: color, height: 1.2);

  // ===== HEADLINE TYPOGRAPHY (Section Headers) =====
  static TextStyle headlineLarge(Color color) =>
      _amiri(size: 28.sp, weight: FontWeight.w600, color: color, height: 1.25);

  static TextStyle headlineMedium(Color color) =>
      _amiri(size: 24.sp, weight: FontWeight.w500, color: color, height: 1.3);

  static TextStyle headlineSmall(Color color) =>
      _amiri(size: 20.sp, weight: FontWeight.w500, color: color, height: 1.35);

  // ===== TITLE TYPOGRAPHY (Card Headers, List Items) =====
  static TextStyle titleLarge(Color color) =>
      _noto(size: 18.sp, weight: FontWeight.w600, color: color, height: 1.3);

  static TextStyle titleMedium(Color color) =>
      _noto(size: 16.sp, weight: FontWeight.w500, color: color, height: 1.35);

  static TextStyle titleSmall(Color color) =>
      _noto(size: 14.sp, weight: FontWeight.w500, color: color, height: 1.4);

  // ===== BODY TYPOGRAPHY (Main Content) =====
  static TextStyle bodyLarge(Color color) =>
      _noto(size: 16.sp, weight: FontWeight.w400, color: color, height: 1.5);

  static TextStyle bodyMedium(Color color) =>
      _noto(size: 14.sp, weight: FontWeight.w400, color: color, height: 1.5);

  static TextStyle bodySmall(Color color) =>
      _noto(size: 12.sp, weight: FontWeight.w400, color: color, height: 1.4);

  // ===== LABEL TYPOGRAPHY (Buttons, Tags, Captions) =====
  static TextStyle labelLarge(Color color) => _noto(
    size: 14.sp,
    weight: FontWeight.w500,
    color: color,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium(Color color) => _noto(
    size: 12.sp,
    weight: FontWeight.w500,
    color: color,
    height: 1.4,
    letterSpacing: 0.15,
  );

  static TextStyle labelSmall(Color color) => _noto(
    size: 10.sp,
    weight: FontWeight.w500,
    color: color,
    height: 1.3,
    letterSpacing: 0.2,
  );

  // ===== SPECIALIZED TYPOGRAPHY =====

  // Quote/Testimonial text
  static TextStyle quote(Color color) => _amiri(
    size: 18.sp,
    weight: FontWeight.w400,
    color: color,
    height: 1.6,
    fontStyle: FontStyle.italic,
  );

  // Featured titles (hero sections)
  static TextStyle featuredTitle(Color color) => _amiri(
    size: 26.sp,
    weight: FontWeight.w700,
    color: color,
    height: 1.3,
    letterSpacing: -0.25,
  );

  // Course titles
  static TextStyle courseTitle(Color color) =>
      _amiri(size: 20.sp, weight: FontWeight.w600, color: color, height: 1.3);

  // Teacher names
  static TextStyle teacherName(Color color) =>
      _noto(size: 14.sp, weight: FontWeight.w500, color: color, height: 1.4);

  // Course descriptions
  static TextStyle courseDescription(Color color) =>
      _noto(size: 14.sp, weight: FontWeight.w400, color: color, height: 1.5);

  // Meta information (duration, lessons count)
  static TextStyle metaInfo(Color color) =>
      _noto(size: 12.sp, weight: FontWeight.w400, color: color, height: 1.3);

  // Button text
  static TextStyle buttonText(Color color) => _noto(
    size: 16.sp,
    weight: FontWeight.w600,
    color: color,
    height: 1.2,
    letterSpacing: 0.1,
  );

  // Navigation labels
  static TextStyle navigationLabel(Color color) =>
      _noto(size: 12.sp, weight: FontWeight.w500, color: color, height: 1.3);

  // Form labels
  static TextStyle formLabel(Color color) =>
      _noto(size: 14.sp, weight: FontWeight.w500, color: color, height: 1.4);

  // Form hints
  static TextStyle formHint(Color color) =>
      _noto(size: 14.sp, weight: FontWeight.w400, color: color, height: 1.4);

  // Error messages
  static TextStyle errorText(Color color) =>
      _noto(size: 12.sp, weight: FontWeight.w400, color: color, height: 1.3);

  // Success messages
  static TextStyle successText(Color color) =>
      _noto(size: 12.sp, weight: FontWeight.w400, color: color, height: 1.3);

  // Price text
  static TextStyle price(Color color) => _poppins(
    size: 16.sp,
    weight: FontWeight.w600,
    color: color,
    height: 1.2,
    letterSpacing: 0.1,
  );

  // Free badge text
  static TextStyle freeBadge(Color color) => _noto(
    size: 12.sp,
    weight: FontWeight.w600,
    color: color,
    height: 1.2,
    letterSpacing: 0.2,
  );

  // Progress text
  static TextStyle progressText(Color color) =>
      _noto(size: 12.sp, weight: FontWeight.w500, color: color, height: 1.3);

  // Caption text
  static TextStyle caption(Color color) => _noto(
    size: 12.sp,
    weight: FontWeight.w400,
    color: color,
    letterSpacing: 0.2,
    height: 1.3,
  );

  // Overline text
  static TextStyle overline(Color color) => _noto(
    size: 10.sp,
    weight: FontWeight.w600,
    color: color,
    letterSpacing: 1.0,
    height: 1.2,
  );

  // ===== ACCESSIBILITY HELPERS =====

  /// Get text style with increased contrast for better accessibility
  static TextStyle withHighContrast(
    TextStyle baseStyle,
    Color backgroundColor,
  ) {
    final luminance = backgroundColor.computeLuminance();
    final contrastColor = luminance > 0.5
        ? AppColors.neutral900
        : AppColors.neutral600;

    return baseStyle.copyWith(color: contrastColor);
  }

  /// Get text style with reduced opacity for disabled states
  static TextStyle withReducedOpacity(TextStyle baseStyle, double opacity) {
    return baseStyle.copyWith(color: baseStyle.color?.withOpacity(opacity));
  }

  /// Get text style for different emphasis levels
  static TextStyle withEmphasis(TextStyle baseStyle, EmphasisLevel level) {
    switch (level) {
      case EmphasisLevel.low:
        return baseStyle.copyWith(
          fontWeight: FontWeight.w400,
          color: baseStyle.color?.withOpacity(0.6),
        );
      case EmphasisLevel.medium:
        return baseStyle.copyWith(fontWeight: FontWeight.w500);
      case EmphasisLevel.high:
        return baseStyle.copyWith(fontWeight: FontWeight.w600);
      case EmphasisLevel.highest:
        return baseStyle.copyWith(fontWeight: FontWeight.w700);
    }
  }
}

// ===== ENUMS =====
enum EmphasisLevel { low, medium, high, highest }

// ===== EXTENSIONS =====
extension TextStyleExtensions on TextStyle {
  /// Apply emphasis level to existing text style
  TextStyle withEmphasis(EmphasisLevel level) {
    return AppTypography.withEmphasis(this, level);
  }

  /// Apply high contrast to existing text style
  TextStyle withHighContrast(Color backgroundColor) {
    return AppTypography.withHighContrast(this, backgroundColor);
  }

  /// Apply reduced opacity to existing text style
  TextStyle withReducedOpacity(double opacity) {
    return AppTypography.withReducedOpacity(this, opacity);
  }
}
