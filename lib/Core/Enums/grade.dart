enum Grade { allGrades, highSchool1, highSchool2, highSchool3 }

extension GradeExtension on Grade {
  String get label {
    switch (this) {
      case Grade.highSchool1:
        return "أولى ثانوي";
      case Grade.highSchool2:
        return "ثانية ثانوي";
      case Grade.highSchool3:
        return "ثالثة ثانوي";
      case Grade.allGrades:
        return "كل المراحل";
    }
  }

  static List<Grade> getAllGrades() => Grade.values;
}
