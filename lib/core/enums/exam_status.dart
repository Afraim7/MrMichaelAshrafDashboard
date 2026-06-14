import 'package:flutter/material.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

/// User-facing exam lifecycle states.
///
/// - [upcoming]    : the window hasn't opened yet.
/// - [active]      : the student can take it now.
/// - [underReview] : the student submitted, but results stay sealed until the
///   exam's `endTime` passes (no answers/score shown yet).
/// - [completed]   : the student has a result AND results are now visible.
/// - [missed]      : the window closed without a submission.
enum ExamStatus { upcoming, active, underReview, missed, completed }

extension ExamStatusX on ExamStatus {
  String get label {
    switch (this) {
      case ExamStatus.active:
        return 'جاري';
      case ExamStatus.underReview:
        return 'تحت المراجعة';
      case ExamStatus.completed:
        return 'تمّ الانتهاء';
      case ExamStatus.missed:
        return 'فاتك';
      case ExamStatus.upcoming:
        return 'قريبًا';
    }
  }

  String get buttonTitle {
    switch (this) {
      case ExamStatus.active:
        return 'ابدأ الامتحان';
      case ExamStatus.underReview:
        return 'تحت المراجعة';
      case ExamStatus.completed:
        return 'عرض النتيجة';
      case ExamStatus.missed:
        return 'أنتهي';
      case ExamStatus.upcoming:
        return 'قريبًا';
    }
  }

  Color get getStateColor {
    switch (this) {
      case ExamStatus.active:
        return AppColors.pastelGreen;
      case ExamStatus.upcoming:
        return AppColors.pastelYellow;
      case ExamStatus.underReview:
        return AppColors.royalYellow;
      case ExamStatus.completed:
        return AppColors.appNavy;
      case ExamStatus.missed:
        return AppColors.tomatoRed;
    }
  }

  Color get statementColor {
    switch (this) {
      case ExamStatus.active:
        return AppColors.pastelGreen;
      case ExamStatus.upcoming:
        return AppColors.pastelYellow;
      case ExamStatus.underReview:
        return AppColors.royalYellow;
      case ExamStatus.completed:
        return AppColors.appNavy;
      case ExamStatus.missed:
        return AppColors.tomatoRed;
    }
  }

  /// Returns a human-friendly Arabic statement describing the current exam
  /// situation. All parameters are optional — only pass what's relevant to
  /// the current status.
  String statement({
    DateTime? startTime,
    DateTime? endTime,
    num? score,
    num? totalMarks,
  }) {
    String fmt(DateTime dt) {
      // "15 يوليو الساعة 8:00 مساءً"
      const months = [
        '',
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final isPm = hour >= 12;
      final h12 = hour % 12 == 0 ? 12 : hour % 12;
      final period = isPm ? 'مساءً' : 'صباحًا';
      return '${dt.day} ${months[dt.month]} الساعة $h12:$minute $period';
    }

    switch (this) {
      case ExamStatus.upcoming:
        if (startTime != null) {
          return 'يبدأ الامتحان يوم ${fmt(startTime)}';
        }
        return 'الامتحان لم يبدأ بعد';

      case ExamStatus.active:
        if (endTime != null) {
          return 'متاح الآن وينتهي يوم ${fmt(endTime)}';
        }
        return 'الامتحان متاح الآن';

      case ExamStatus.underReview:
        return 'تم استلام إجاباتك بنجاح، وستظهر النتيجة بعد انتهاء الامتحان.';

      case ExamStatus.completed:
        if (score != null && totalMarks != null) {
          return 'الدرجة : ${score.toInt()} من ${totalMarks.toInt()}';
        }
        return 'لقد أنهيت هذا الامتحان';

      case ExamStatus.missed:
        if (endTime != null) {
          return 'انتهى هذا الامتحان يوم ${fmt(endTime)}';
        }
        return 'لقد فاتك هذا الامتحان';
    }
  }
}
