
enum Teacher {
  mrMichaelAshraf
}

extension TeacherLabel on Teacher {
  String get label {
    switch (this) {
      case Teacher.mrMichaelAshraf :
      return 'مستر مايكل أشرف';

    }
  }
}