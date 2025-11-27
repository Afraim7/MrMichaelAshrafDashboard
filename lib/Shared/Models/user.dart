import 'dart:convert';
import 'package:mrmichaelashrafdashboard/Core/Config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/area.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/gender.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/government.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/grade.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/stage.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/user_role.dart';

class AppUser {
  final String userID;
  final String userName;
  final String email;
  final Gender gender;
  final Government state;
  final String phone;
  final Stage stage;
  final Grade grade;
  final String parentPhone;
  final bool? emailVerified;
  final String photoURL;
  final UserRole role;
  final List<int> enrolledCoursesIDs;
  final int enrolledCoursesCount;
  final int watchedHours;
  final int takenExamsCount;

  AppUser({
    required this.userID,
    required this.userName,
    required this.email,
    required this.gender,
    required this.state,
    required this.phone,
    required this.stage,
    required this.grade,
    required this.parentPhone,
    this.emailVerified = false,
    String? photoURL,
    this.role = UserRole.student,
    this.enrolledCoursesIDs = const [],
    this.enrolledCoursesCount = 0,
    this.watchedHours = 0,
    this.takenExamsCount = 0,
  }) : photoURL = photoURL ?? _setProgilePicture(gender, role);

  static String _setProgilePicture(Gender gender, UserRole role) {
    if (role == UserRole.student) {
      return (gender == Gender.male)
          ? AppAssets.images.maleStudent
          : AppAssets.images.femaleStudent;
    } else if (role == UserRole.admin) {
      return AppAssets.images.admin;
    }
    return AppAssets.images.defaultAvatar;
  }

  String _setProgileIcon(Gender gender, UserRole role) {
    if (role == UserRole.student) {
      return (gender == Gender.male)
          ? AppAssets.images.maleStudent
          : AppAssets.images.femaleStudent;
    } else if (role == UserRole.admin) {
      return AppAssets.images.admin;
    }
    return AppAssets.images.defaultAvatar;
  }

  AppUser copyWith({
    String? userID,
    String? userName,
    String? email,
    bool? emailVerified,
    String? photoURL,
    Gender? gender,
    Government? state,
    String? phone,
    Stage? stage,
    Grade? grade,
    String? parentPhone,
    UserRole? role,
    List<int>? enrolledCoursesIDs,
    int? enrolledCoursesCount,
    int? watchedHours,
    int? takenExamsCount,
  }) {
    return AppUser(
      userID: userID ?? this.userID,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      photoURL: photoURL ?? this.photoURL,
      gender: gender ?? this.gender,
      state: state ?? this.state,
      phone: phone ?? this.phone,
      stage: stage ?? this.stage,
      grade: grade ?? this.grade,
      parentPhone: parentPhone ?? this.parentPhone,
      role: role ?? this.role,
      enrolledCoursesIDs: enrolledCoursesIDs ?? this.enrolledCoursesIDs,
      enrolledCoursesCount: enrolledCoursesCount ?? this.enrolledCoursesCount,
      watchedHours: watchedHours ?? this.watchedHours,
      takenExamsCount: takenExamsCount ?? this.takenExamsCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'userName': userName,
      'email': email,
      'gender': gender.name,
      'state': state.name,
      'phone': phone,
      'stage': stage.name,
      'grade': grade.name,
      'parentPhone': parentPhone,
      'emailVerified': emailVerified,
      'photoURL': photoURL,
      'role': role.name,
      'enrolledCourses': enrolledCoursesIDs,
      'enrolledCoursesCount': enrolledCoursesCount,
      'watchedHours': watchedHours,
      'takenExamsCount': takenExamsCount,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    String? asString(dynamic v) => v is String ? v : null;
    String lower(String v) => v.trim().toLowerCase();

    Gender parseGender(dynamic v) {
      final s = asString(v) ?? '';
      final byName = Gender.values
          .where((e) => e.name == s)
          .cast<Gender?>()
          .firstWhere((e) => e != null, orElse: () => null);
      if (byName != null) return byName;
      final byLabel = GenderLabel.fromLabel(s);
      return byLabel ?? Gender.male;
    }

    Government parseGovernment(dynamic v) {
      final s = asString(v) ?? '';
      final byName = Government.values
          .where((e) => e.name == s)
          .cast<Government?>()
          .firstWhere((e) => e != null, orElse: () => null);
      if (byName != null) return byName;
      final byLabel = GovernmentX.fromLabel(s);
      return byLabel ?? Government.cairo;
    }

    Area parseArea(dynamic v) {
      final s = asString(v) ?? '';
      final byName = Area.values
          .where((e) => e.name == s)
          .cast<Area?>()
          .firstWhere((e) => e != null, orElse: () => null);
      if (byName != null) return byName;
      final byLabel = AreaX.fromLabel(s);
      return byLabel ?? Area.khanka;
    }

    Grade parseGrade(dynamic v) {
      final s = asString(v) ?? '';
      final byName = Grade.values
          .where((e) => e.name == s)
          .cast<Grade?>()
          .firstWhere((e) => e != null, orElse: () => null);
      if (byName != null) return byName;
      // fallback by label
      for (final g in Grade.values) {
        if (g.label == s) return g;
      }
      return Grade.allGrades;
    }

    Stage parseStage(dynamic v) {
      final s = asString(v) ?? '';
      final byName = Stage.values
          .where((e) => e.name == s)
          .cast<Stage?>()
          .firstWhere((e) => e != null, orElse: () => null);
      if (byName != null) return byName;
      // fallback by label
      for (final st in Stage.values) {
        if (st.label == s) return st;
      }
      return Stage.highSchool;
    }

    UserRole parseRole(dynamic v) {
      final s = asString(v) ?? '';
      final byName = UserRole.values
          .where((e) => e.name == s)
          .cast<UserRole?>()
          .firstWhere((e) => e != null, orElse: () => null);
      if (byName != null) return byName;
      for (final r in UserRole.values) {
        if (r.label == s) return r;
      }
      return UserRole.student;
    }

    int? asInt(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    int parseCount(dynamic value) {
      if (value == null) return 0;
      final parsed = asInt(value);
      if (parsed != null) return parsed < 0 ? 0 : parsed;
      if (value is Iterable) return value.length;
      if (value is Map) return value.length;
      return 0;
    }

    List<int> parseEnrolledCourses(dynamic rawCourses) {
      if (rawCourses is Iterable) {
        return rawCourses.map(asInt).whereType<int>().toList();
      }
      if (rawCourses is Map) {
        return rawCourses.keys.map(asInt).whereType<int>().toList();
      }
      return const <int>[];
    }

    int resolveTakenExamsCount(Map<String, dynamic> source) {
      final directCount = parseCount(source['takenExamsCount']);
      if (directCount > 0) return directCount;

      const fallbackKeys = [
        'takenExams',
        'completedExams',
        'finishedExams',
        'examHistory',
        'examResults',
      ];

      for (final key in fallbackKeys) {
        final fallback = parseCount(source[key]);
        if (fallback > 0) return fallback;
      }

      return 0;
    }

    final enrolledCoursesList = parseEnrolledCourses(map['enrolledCourses']);
    final explicitCoursesCount = parseCount(map['enrolledCoursesCount']);
    final resolvedCoursesCount = explicitCoursesCount > 0
        ? explicitCoursesCount
        : enrolledCoursesList.length;

    final resolvedTakenExamsCount = resolveTakenExamsCount(map);

    return AppUser(
      userID: map['userID'] ?? '0000000',
      userName: map['userName'] ?? 'UnKnow',
      email: map['email'] ?? 'unknown@mrmichaelashrafdashboard.com',
      emailVerified: map['emailVerified'] ?? false,
      photoURL: map['photoURL'] ?? 'assets/images/defaultavatar.jpg',
      gender: parseGender(map['gender']),
      state: parseGovernment(map['state']),
      phone: map['phone'] ?? '01200000000',
      stage: parseStage(map['stage']),
      grade: parseGrade(map['grade']),
      parentPhone: map['parentPhone'] ?? '01000000000',
      role: parseRole(map['role']),
      enrolledCoursesIDs: enrolledCoursesList,
      enrolledCoursesCount: resolvedCoursesCount,
      watchedHours: (map['watchedHours'] as num?)?.toInt() ?? 0,
      takenExamsCount: resolvedTakenExamsCount,
    );
  }

  factory AppUser.fromJson(String source) =>
      AppUser.fromMap(Map<String, dynamic>.from(jsonDecode(source)));

  String toJson() => jsonEncode(toMap());

  String get setProfileIcon => _setProgileIcon(gender, role);
}
