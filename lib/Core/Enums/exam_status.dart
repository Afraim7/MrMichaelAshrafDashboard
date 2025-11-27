import 'package:flutter/material.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';

enum ExamStatus { active, upcoming, completed, missed, done }

extension ExamStatusX on ExamStatus {
  String get label {
    switch (this) {
      case ExamStatus.active:
        return 'جاري';
      case ExamStatus.completed:
        return 'تمّ الانتهاء';
      case ExamStatus.missed:
        return 'فاتك';
      case ExamStatus.upcoming:
        return 'قريبًا';
      case ExamStatus.done:
        return 'أنتهي';
    }
  }

  String get buttonTitle {
    switch (this) {
      case ExamStatus.active:
        return 'ابدأ الامتحان';
      case ExamStatus.completed:
        return 'عرض النتيجة';
      case ExamStatus.missed:
        return 'انتهى';
      case ExamStatus.upcoming:
        return 'قريبًا';
      case ExamStatus.done:
        return 'أنتهي';
    }
  }

  Color get getStateColor {
    switch (this) {
      case ExamStatus.active:
        return AppColors.pastelGreen;
      case ExamStatus.upcoming:
        return AppColors.royalYellow;
      case ExamStatus.completed:
        return AppColors.midBlue;
      case ExamStatus.missed:
        return AppColors.tomatoRed;
      case ExamStatus.done:
        return AppColors.skyBlue;
    }
  }
}
