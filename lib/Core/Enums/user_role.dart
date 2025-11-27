enum UserRole {
  student,
  admin,
}

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.student:
        return 'طالب';
      case UserRole.admin:
        return 'ادمن';
    }
  }
}


