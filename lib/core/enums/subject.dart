enum Subject {
  geography,
  history,
}

extension SubjectX on Subject {
  String get label {
    switch(this) {
      case Subject.geography : return 'جغرافيا';
      case Subject.history : return 'تاريخ';
    }
  }
  static List<Subject> getAllSubjects() => Subject.values;
}


