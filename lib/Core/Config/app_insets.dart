import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Global inset (padding & margin) system.
/// Semantic, responsive, and directional for perfect alignment.
class AppInsets {
  AppInsets._();

  // Uniform insets (all sides)
  static EdgeInsets xs = EdgeInsets.all(4.r);
  static EdgeInsets sm = EdgeInsets.all(8.r);
  static EdgeInsets md = EdgeInsets.all(14.r); // default Inset size
  static EdgeInsets lg = EdgeInsets.all(24.r);
  static EdgeInsets xl = EdgeInsets.all(32.r);
  static EdgeInsets xxl = EdgeInsets.all(48.r);

  // Symmetric insets
  static EdgeInsets hXs = EdgeInsets.symmetric(horizontal: 4.w);
  static EdgeInsets hSm = EdgeInsets.symmetric(horizontal: 8.w);
  static EdgeInsets hMd = EdgeInsets.symmetric(horizontal: 14.w);
  static EdgeInsets hLg = EdgeInsets.symmetric(horizontal: 24.w);
  static EdgeInsets hXl = EdgeInsets.symmetric(horizontal: 32.w);

  static EdgeInsets vXs = EdgeInsets.symmetric(vertical: 4.h);
  static EdgeInsets vSm = EdgeInsets.symmetric(vertical: 8.h);
  static EdgeInsets vMd = EdgeInsets.symmetric(vertical: 14.h);
  static EdgeInsets vLg = EdgeInsets.symmetric(vertical: 24.h);
  static EdgeInsets vXl = EdgeInsets.symmetric(vertical: 32.h);

  // Directional insets (single side)
  static EdgeInsets topXs = EdgeInsets.only(top: 4.h);
  static EdgeInsets topSm = EdgeInsets.only(top: 8.h);
  static EdgeInsets topMd = EdgeInsets.only(top: 14.h);
  static EdgeInsets topLg = EdgeInsets.only(top: 24.h);
  static EdgeInsets topXl = EdgeInsets.only(top: 32.h);

  static EdgeInsets bottomXs = EdgeInsets.only(bottom: 4.h);
  static EdgeInsets bottomSm = EdgeInsets.only(bottom: 8.h);
  static EdgeInsets bottomMd = EdgeInsets.only(bottom: 14.h);
  static EdgeInsets bottomLg = EdgeInsets.only(bottom: 24.h);
  static EdgeInsets bottomXl = EdgeInsets.only(bottom: 32.h);

  static EdgeInsets leftXs = EdgeInsets.only(left: 4.w);
  static EdgeInsets leftSm = EdgeInsets.only(left: 8.w);
  static EdgeInsets leftMd = EdgeInsets.only(left: 14.w);
  static EdgeInsets leftLg = EdgeInsets.only(left: 24.w);
  static EdgeInsets leftXl = EdgeInsets.only(left: 32.w);

  static EdgeInsets rightXs = EdgeInsets.only(right: 4.w);
  static EdgeInsets rightSm = EdgeInsets.only(right: 8.w);
  static EdgeInsets rightMd = EdgeInsets.only(right: 14.w);
  static EdgeInsets rightLg = EdgeInsets.only(right: 24.w);
  static EdgeInsets rightXl = EdgeInsets.only(right: 32.w);

  // Common layouts
  static EdgeInsets page = EdgeInsets.all(14.r);
  static EdgeInsets section = EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h);
  static EdgeInsets card = EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h);


  // Custom insets
  static EdgeInsets top(double value) => EdgeInsets.only(top: value.h);
  static EdgeInsets bottom(double value) => EdgeInsets.only(bottom: value.h);
  static EdgeInsets left(double value) => EdgeInsets.only(left: value.w);
  static EdgeInsets right(double value) => EdgeInsets.only(right: value.w);
  static EdgeInsets horizontal(double value) => EdgeInsets.symmetric(horizontal: value.w);
  static EdgeInsets vertical(double value) => EdgeInsets.symmetric(vertical: value.h);
  static EdgeInsets all(double value) => EdgeInsets.all(value.r);
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal.w, vertical: vertical.h);
  static EdgeInsetsDirectional only({double top = 0, double bottom = 0, double start = 0, double end = 0}) => EdgeInsetsDirectional.only(start: start.w, end: end.w, top: top.h, bottom: bottom.h);
  
}
