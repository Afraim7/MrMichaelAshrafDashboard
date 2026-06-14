import 'dart:convert';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/enums/button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/features/courses/presentation/widgets/course_enrollment_sheet.dart';
import 'package:mrmichaelashrafdashboard/features/courses/presentation/widgets/course_sheet.dart';
import 'package:mrmichaelashrafdashboard/features/exams/presentation/widgets/exam_results_sheet.dart';
import 'package:mrmichaelashrafdashboard/features/exams/presentation/widgets/exam_sheet.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/presentation/widgets/highlight_sheet.dart';
import 'package:mrmichaelashrafdashboard/shared/dialogs/app_bottom_sheet.dart';
import 'package:mrmichaelashrafdashboard/shared/dialogs/app_dialog.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/app_snack_bar.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';

class DashboardHelper {
  DashboardHelper._();

  // Screen Dimensions
  static double screenHeight = 1.sh;
  static double screenWidth = 1.sw;
  static double appBarHeight = kTextTabBarHeight.h;
  static double bottomNavBarHeight = kBottomNavigationBarHeight.h;
  static double statusBarHeight = ScreenUtil().statusBarHeight;
  static double bottomSafeArea = ScreenUtil().bottomBarHeight;
  static double usableHeight({bool withAppBar = true}) {
    double height = 1.sh - ScreenUtil().statusBarHeight;
    if (withAppBar) height -= kToolbarHeight.h;
    return height;
  }

  static double getDashboardBarTopSpacing(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (!isMobile) return 20;

    final safeAreaTop = MediaQuery.of(context).padding.top;
    return safeAreaTop + 20;
  }

  static bool currentPlatformIsWeb = kIsWeb;

  static Widget appLogo = AnimatedTextKit(
    repeatForever: false,
    totalRepeatCount: 1,
    animatedTexts: [
      TyperAnimatedText(
        '\nمستر \n مايكل \n أشرف',
        textStyle: GoogleFonts.amiri(
          fontSize: 24,
          fontWeight: FontWeight.w100,
          color: AppColors.appWhite,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );

  static AppBar mainAppBar({required String screenTitle}) {
    return AppBar(
      backgroundColor: AppColors.appBlack,
      surfaceTintColor: AppColors.appTransperent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leadingWidth: 60.w,
      shape: Border(
        bottom: BorderSide(width: 0.2, color: AppColors.appNavy.withAlpha(50)),
      ),
      title: Text(
        screenTitle,
        style: GoogleFonts.amiri(
          fontSize: 16.sp,
          color: AppColors.appWhite,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }

  static void showTheSnackBar(
    BuildContext context, {
    required String message,
    Color backgroundColor = AppColors.posterRed,
    String? icon,
  }) {
    AppSnackBar(
      message: message,
      backgroundColor: backgroundColor.withAlpha(230),
      icon: icon,
    ).showSnackBar(context);
  }

  static void showErrorBar(BuildContext context, {required String error}) {
    AppSnackBar(
      message: error,
      backgroundColor: AppColors.posterRed.withAlpha(230),
      icon: AppAssets.animations.redWarning,
    ).showSnackBar(context);
  }

  static void showSuccessBar(BuildContext context, {required String message}) {
    AppSnackBar(
      message: message,
      backgroundColor: AppColors.pastelGreen.withAlpha(230),
      icon: AppAssets.animations.checkedSuccess,
    ).showSnackBar(context);
  }

  /// Warning variant — used for soft-confirmation messages like "you have
  /// unsaved changes" before letting the user discard a manager form.
  static void showWarningBar(BuildContext context, {required String message}) {
    AppSnackBar(
      message: message,
      backgroundColor: AppColors.royalYellow.withAlpha(230),
      icon: AppAssets.animations.yellowWarning,
    ).showSnackBar(context);
  }

  static Widget appCircularInd = CircularProgressIndicator(
    strokeWidth: 2,
    color: AppColors.skyBlue,
    backgroundColor: AppColors.neutral900,
  );

  static Widget buildProfilImage(String image, double size) {
    if (image.startsWith('http')) {
      return Image.network(image, height: size, width: size, fit: BoxFit.cover);
    } else if (image.startsWith('data:image')) {
      final base64Data = image.split(',').last;
      final bytes = base64Decode(base64Data);
      return Image.memory(bytes, height: size, width: size, fit: BoxFit.cover);
    } else if (!kIsWeb && File(image).existsSync()) {
      return Image.file(
        File(image),
        height: size,
        width: size,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(image, height: size, width: size, fit: BoxFit.cover);
    }
  }

  static void showVerificationBar(
    BuildContext context, {
    required String message,
  }) {
    AppSnackBar(
      message: message,
      backgroundColor: AppColors.pastelGreen.withAlpha(230),
      icon: AppAssets.animations.verifiedSuccess,
    ).showSnackBar(context);
  }

  static void showCoursesManager({
    required BuildContext context,
    Course? existingCourse,
    Function(Course)? onSaveUpdates,
    Function()? onPublish,
    Function()? onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CourseSheet(
        existingCourse: existingCourse,
        onDelete: onDelete,
        onSaveUpdates: onSaveUpdates,
        onPublish: onPublish,
      ),
    );
  }

  static void showExamsManager({
    required BuildContext context,
    Exam? existingExam,
    Function(Exam)? onSaveUpdates,
    Function()? onPublish,
    Function()? onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExamSheet(
        existingExam: existingExam,
        onDelete: onDelete,
        onSaveUpdates: onSaveUpdates,
        onPublish: onPublish,
      ),
    );
  }

  static void showHighlightManagerSheet({
    required BuildContext context,
    Highlight? existingHighlight,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HighlightSheet(existingHighlight: existingHighlight),
    );
  }

  /// Opens the [ExamResultsSheet]. The sheet fetches its own data and shows
  /// its own loading / error states — no pre-fetch needed here.
  ///
  /// Returns a future that completes when the sheet is dismissed, so callers
  /// (e.g. exams_center) can `await` it to drive per-card loading indicators.
  static Future<void> showExamResultsSheet({
    required BuildContext context,
    required Exam exam,
  }) {
    return AppBottomSheet(
      child: ExamResultsSheet(exam: exam),
    ).showBottomSheet(context);
  }

  /// Opens the [CourseEnrollmentsSheet]. Mirrors [showExamResultsSheet] —
  /// the sheet owns its own loading / error / mutation lifecycle, so the
  /// caller just awaits dismissal.
  static Future<void> showCourseEnrollmentsSheet({
    required BuildContext context,
    required Course course,
  }) {
    return AppBottomSheet(
      child: CourseEnrollmentSheet(course: course),
    ).showBottomSheet(context);
  }

  static void showAppDialog(
    BuildContext context, {
    required String header,
    required String description,
    required String lottiePath,
    required VoidCallback onConfirm,
    ButtonState? onConfirmState,
    bool listenToCubit = false,
    String cancelTitle = 'إلغاء',
    String confirmTitle = 'تأكيد',
    Color cancelColor = AppColors.surfaceDark,
    Color confirmColor = AppColors.posterRed,
    bool barrierDismissible = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AppDialog(
        header: header,
        description: description,
        lottiePath: lottiePath,
        onConfirm: onConfirm,
        onConfirmState: onConfirmState,
        cancelTitle: cancelTitle,
        confirmTitle: confirmTitle,
        cancelColor: cancelColor,
        confirmColor: confirmColor,
      ),
    );
  }

  static void openTheBottomSheet(
    BuildContext context, {
    required Widget child,
  }) {
    AppBottomSheet(child: child).showBottomSheet(context);
  }
}
