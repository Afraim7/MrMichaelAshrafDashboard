enum Stage {
  highSchool,
  preparatorySchool,
}

extension StageX on Stage {
  String get label {
    switch (this) {
      case Stage.highSchool:
        return 'المرحلة الثانوية';
      case Stage.preparatorySchool:
        return 'المرحلة الإعدادية';
    }
  }

  static Stage? fromLabel(String label) {
    return Stage.values.firstWhere(
      (stage) => stage.label == label,
      orElse: () => Stage.highSchool,
    );
  }
}


