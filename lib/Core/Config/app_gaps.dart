import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppGaps {
  AppGaps._();

  // ===== SPACING SCALE (8pt grid system) =====
  // Based on Material Design 3 spacing guidelines
  // Each unit represents 4dp, creating a consistent 8pt grid

  // ===== VERTICAL GAPS =====
  static SizedBox get v0 => SizedBox(height: 0.h);
  static SizedBox get v1 => SizedBox(height: 4.h);   // 4dp
  static SizedBox get v2 => SizedBox(height: 8.h);   // 8dp
  static SizedBox get v3 => SizedBox(height: 12.h);  // 12dp
  static SizedBox get v4 => SizedBox(height: 16.h);  // 16dp
  static SizedBox get v5 => SizedBox(height: 20.h);  // 20dp
  static SizedBox get v6 => SizedBox(height: 24.h);  // 24dp
  static SizedBox get v8 => SizedBox(height: 32.h);  // 32dp
  static SizedBox get v10 => SizedBox(height: 40.h); // 40dp
  static SizedBox get v12 => SizedBox(height: 48.h); // 48dp
  static SizedBox get v16 => SizedBox(height: 64.h); // 64dp
  static SizedBox get v20 => SizedBox(height: 80.h); // 80dp
  static SizedBox get v24 => SizedBox(height: 96.h); // 96dp
  static SizedBox get v32 => SizedBox(height: 128.h); // 128dp

  // ===== HORIZONTAL GAPS =====
  static SizedBox get h0 => SizedBox(width: 0.w);
  static SizedBox get h1 => SizedBox(width: 4.w);    // 4dp
  static SizedBox get h2 => SizedBox(width: 8.w);    // 8dp
  static SizedBox get h3 => SizedBox(width: 12.w);   // 12dp
  static SizedBox get h4 => SizedBox(width: 16.w);   // 16dp
  static SizedBox get h5 => SizedBox(width: 20.w);   // 20dp
  static SizedBox get h6 => SizedBox(width: 24.w);   // 24dp
  static SizedBox get h8 => SizedBox(width: 32.w);   // 32dp
  static SizedBox get h10 => SizedBox(width: 40.w);  // 40dp
  static SizedBox get h12 => SizedBox(width: 48.w);  // 48dp
  static SizedBox get h16 => SizedBox(width: 64.w);  // 64dp
  static SizedBox get h20 => SizedBox(width: 80.w);  // 80dp
  static SizedBox get h24 => SizedBox(width: 96.w);  // 96dp
  static SizedBox get h32 => SizedBox(width: 128.w); // 128dp

  // ===== SEMANTIC SPACING =====
  // These provide meaning to the spacing, making the code more readable
  
  // Micro spacing (for tight layouts)
  static SizedBox get microV => v1;
  static SizedBox get microH => h1;
  
  // Small spacing (for related elements)
  static SizedBox get smallV => v2;
  static SizedBox get smallH => h2;
  
  // Medium spacing (for sections)
  static SizedBox get mediumV => v4;
  static SizedBox get mediumH => h4;
  
  // Large spacing (for major sections)
  static SizedBox get largeV => v6;
  static SizedBox get largeH => h6;
  
  // Extra large spacing (for page sections)
  static SizedBox get xlV => v8;
  static SizedBox get xlH => h8;
  
  // Section spacing (for major page divisions)
  static SizedBox get sectionV => v12;
  static SizedBox get sectionH => h12;
  
  // Page spacing (for full page divisions)
  static SizedBox get pageV => v16;
  static SizedBox get pageH => h16;

  // ===== COMPONENT-SPECIFIC SPACING =====
  
  // Card spacing
  static SizedBox get cardPaddingV => v4;
  static SizedBox get cardMarginV => v2;
  static SizedBox get cardContentV => v3;
  
  // Button spacing
  static SizedBox get buttonPaddingV => v2;
  static SizedBox get buttonMarginV => v1;
  static SizedBox get buttonGroupV => h2;
  
  // Form spacing
  static SizedBox get formFieldV => v4;
  static SizedBox get formSectionV => v6;
  static SizedBox get formGroupV => v3;
  
  // List spacing
  static SizedBox get listItemV => v2;
  static SizedBox get listSectionV => v4;
  static SizedBox get listHeaderV => v3;
  
  // Navigation spacing
  static SizedBox get navItemV => v1;
  static SizedBox get navSectionV => v3;
  static SizedBox get navHeaderV => v2;
  
  // Content spacing
  static SizedBox get contentBlockV => v4;
  static SizedBox get contentSectionV => v6;
  static SizedBox get contentPageV => v8;
  
  // ===== RESPONSIVE SPACING =====
  // These adjust based on screen size for better mobile/tablet experience
  
  static SizedBox responsiveVertical(double baseValue) {
    return SizedBox(height: (baseValue * ScreenUtil().scaleHeight).h);
  }
  
  static SizedBox responsiveHorizontal(double baseValue) {
    return SizedBox(width: (baseValue * ScreenUtil().scaleWidth).w);
  }
  
  // ===== CUSTOM SPACING =====
  // For when you need specific spacing values
  
  static SizedBox customVertical(double value) => SizedBox(height: value.h);
  static SizedBox customHorizontal(double value) => SizedBox(width: value.w);
  
  // ===== SPACING UTILITIES =====
  
  /// Create a spacer with flexible height
  
  static Widget get flexibleVertical => const Spacer();

  /// Create a spacer with flexible width
  static Widget get flexibleHorizontal => const Spacer();
  
  /// Create a spacer with specific flex value
  static Widget flexible({int flex = 1}) => Spacer(flex: flex);
  
  /// Create a divider with standard spacing
  static Widget divider({Color? color, double? thickness}) {
    return Divider(
      color: color,
      thickness: thickness ?? 1,
      height: v2.height,
    );
  }
  
  /// Create a vertical divider with standard spacing
  static Widget verticalDivider({Color? color, double? thickness}) {
    return VerticalDivider(
      color: color?? Colors.transparent,
      thickness: thickness ?? 1,
      width: h2.width,
    );
  }


  // ===== MISSING HORIZONTAL COMPONENT SPACING =====
  
  // Card spacing
  static SizedBox get cardPaddingH => h4;
  static SizedBox get cardMarginH => h2;
  static SizedBox get cardContentH => h3;
  
  // Button spacing
  static SizedBox get buttonPaddingH => h2;
  static SizedBox get buttonMarginH => h1;
  static SizedBox get buttonGroupH => h2;
  
  // Form spacing
  static SizedBox get formFieldH => h4;
  static SizedBox get formSectionH => h6;
  static SizedBox get formGroupH => h3;
  
  // List spacing
  static SizedBox get listItemH => h2;
  static SizedBox get listSectionH => h4;
  static SizedBox get listHeaderH => h3;
  
  // Navigation spacing
  static SizedBox get navItemH => h1;
  static SizedBox get navSectionH => h3;
  static SizedBox get navHeaderH => h2;
  
  // Content spacing
  static SizedBox get contentBlockH => h4;
  static SizedBox get contentSectionH => h6;
  static SizedBox get contentPageH => h8;

  // ===== EDGE CASE SPACING VALUES =====
  
  // Very small spacing (for fine adjustments)
  static SizedBox get tinyV => SizedBox(height: 2.h);
  static SizedBox get tinyH => SizedBox(width: 2.w);
  
  // Very large spacing (for major page divisions)
  static SizedBox get hugeV => SizedBox(height: 160.h);
  static SizedBox get hugeH => SizedBox(width: 160.w);
  
  // Massive spacing (for full-screen sections)
  static SizedBox get massiveV => SizedBox(height: 256.h);
  static SizedBox get massiveH => SizedBox(width: 256.w);


  /// Create responsive padding based on screen size
  static EdgeInsets responsivePadding(BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final multiplier = screenWidth > 600 ? 1.2 : 1.0;
    
    return EdgeInsets.only(
      left: (left ?? horizontal ?? all ?? 0) * multiplier,
      top: (top ?? vertical ?? all ?? 0) * multiplier,
      right: (right ?? horizontal ?? all ?? 0) * multiplier,
      bottom: (bottom ?? vertical ?? all ?? 0) * multiplier,
    );
  }


  /// Create a centered spacer (both directions)
  static Widget flexibleBoth({int flex = 1}) => Spacer(flex: flex);
  
  /// Create a divider with custom spacing and styling
  static Widget customDivider({
    Color? color,
    double? thickness,
    double? height,
    double? indent,
    double? endIndent,
  }) {
    return Divider(
      color: color,
      thickness: thickness ?? 1,
      height: height ?? v2.height,
      indent: indent ?? 0,
      endIndent: endIndent ?? 0,
    );
  }
  
  /// Create a vertical divider with custom spacing and styling
  static Widget customVerticalDivider({
    Color? color,
    double? thickness,
    double? width,
    double? indent,
    double? endIndent,
  }) {
    return VerticalDivider(
      color: color ?? Colors.transparent,
      thickness: thickness ?? 1,
      width: width ?? h2.width,
      indent: indent ?? 0,
      endIndent: endIndent ?? 0,
    );
  }


  // ===== RESPONSIVE FONT SIZE =====
  /// Set responsive font size for web widgets
  static double setFontSize(BuildContext context, {required double sizeForMobile, required double sizeForDesktop}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth > 600) ? sizeForDesktop : sizeForMobile;
  }
  
  /// Get responsive font size with scaling
  double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth > 600 ? 1.2 : 1.0;
    return baseSize * scaleFactor;
  }

  
 
}
