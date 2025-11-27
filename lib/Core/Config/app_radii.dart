import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class AppRadii {
  AppRadii._();


  // Standard circular borders
  static BorderRadius xs = BorderRadius.circular(4.r);
  static BorderRadius sm = BorderRadius.circular(8.r);
  static BorderRadius md = BorderRadius.circular(12.r);
  static BorderRadius lg = BorderRadius.circular(16.r);
  static BorderRadius xl = BorderRadius.circular(20.r);
  static BorderRadius xxl = BorderRadius.circular(24.r);
  static BorderRadius xxxl = BorderRadius.circular(28.r);
  static BorderRadius rounded = BorderRadius.circular(35.r);
  static BorderRadius huge = BorderRadius.circular(40.r);
  static BorderRadius extraHuge = BorderRadius.circular(50.r);
  static BorderRadius ultra = BorderRadius.circular(60.r);

  // Circle & pill shapes
  static BorderRadius pill = BorderRadius.circular(1000.r);
  static BorderRadius circle(double size) => BorderRadius.circular(size / 2);

  // Vertical circular borders
  static BorderRadius topSheet = BorderRadius.vertical(top: Radius.circular(30.r));
  static BorderRadius bottomSheet = BorderRadius.vertical(top: Radius.circular(40.r));
  static BorderRadius dialog = BorderRadius.circular(25.r);

  // Elliptical borders
  static BorderRadius topSheetElliptical = BorderRadius.vertical(top: Radius.elliptical(80.w, 40.h));
  static BorderRadius bottomSheetElliptical = BorderRadius.vertical(top: Radius.elliptical(80.w, 60.h));
  static BorderRadius dialogElliptical = BorderRadius.vertical(top: Radius.elliptical(40.w, 25.h), bottom: Radius.elliptical(40.w, 25.h));


  static BorderRadius custom({double topLeft = 0, double topRight = 0, double bottomLeft = 0, double bottomRight = 0}) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft.r),
      topRight: Radius.circular(topRight.r),
      bottomLeft: Radius.circular(bottomLeft.r),
      bottomRight: Radius.circular(bottomRight.r),
    );
  }

  static BorderRadius elliptical({double topLeftX = 0, double topLeftY = 0, double topRightX = 0, double topRightY = 0, double bottomLeftX = 0, double bottomLeftY = 0, double bottomRightX = 0, double bottomRightY = 0}) {
    return BorderRadius.only(
      topLeft: Radius.elliptical(topLeftX.w, topLeftY.h),
      topRight: Radius.elliptical(topRightX.w, topRightY.h),
      bottomLeft: Radius.elliptical(bottomLeftX.w, bottomLeftY.h),
      bottomRight: Radius.elliptical(bottomRightX.w, bottomRightY.h),
    );
  }

  static BorderRadius circular(double radius) => BorderRadius.circular(radius.r);

}
