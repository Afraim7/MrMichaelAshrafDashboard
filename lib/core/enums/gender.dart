enum Gender {
  male,
  female,
}

extension GenderLabel on Gender {
  
  static List<Gender> getAllGenders() => Gender.values;

  String get label {
    switch (this) {
      case Gender.male: return 'ذكر';
      case Gender.female: return 'أنثى';
    }
  }

  static Gender? fromLabel(String label) {
    for (final g in Gender.values) {
      if (g.label == label) return g;
    }
    return null;
  }
}


