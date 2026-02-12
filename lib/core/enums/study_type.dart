enum StudyType { onlineStudent, centerStudent }

extension StudyTypeLabel on StudyType {
  static List<StudyType> getAllStudyTypes() => StudyType.values;

  String get label {
    switch (this) {
      case StudyType.onlineStudent:
        return 'اونلاين';
      case StudyType.centerStudent:
        return 'سنتر';
    }
  }

  static StudyType? fromLabel(String label) {
    for (final type in StudyType.values) {
      if (type.label == label) return type;
    }
    return null;
  }
}
