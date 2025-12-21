import 'dart:convert';
import 'package:mrmichaelashrafdashboard/Core/Config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/gender.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/government.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/grade.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/stage.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/study_type.dart';

class AppUser {
  // will be set from firebase auth
  final String userID;

  // must be provided by the user
  final String userName;
  final String email;
  final Gender gender;
  final Government state;
  final String area;
  final String phone;
  final Stage stage;
  final Grade grade;
  final StudyType studyType;
  final String parentPhone;

  // will be set with some operations
  final bool?
  emailVerified; // once email is verified - right after creating the account so the default will be false till then
  final String photoURL; // static images path will be passed based on gender

  // will be calculated later
  final List<int> enrolledCoursesIDs;
  final int enrolledCoursesCount;
  final int takenExamsCount;

  AppUser({
    required this.userID,
    required this.userName,
    required this.email,
    required this.gender,
    required this.state,
    required this.area,
    required this.phone,
    required this.stage,
    required this.grade,
    required this.studyType,
    required this.parentPhone,
    this.emailVerified = false,
    String? photoURL,
    this.enrolledCoursesIDs = const [],
    this.enrolledCoursesCount = 0,
    this.takenExamsCount = 0,
  }) : photoURL = photoURL ?? _setProfilePicture(gender);

  static String _setProfilePicture(Gender gender) {
    return (gender == Gender.male)
        ? AppAssets.images.maleStudent
        : (gender == Gender.female)
        ? AppAssets.images.femaleStudent
        : AppAssets.images.defaultAvatar;
  }

  AppUser copyWith({
    String? userID,
    String? userName,
    String? email,
    bool? emailVerified,
    String? photoURL,
    Gender? gender,
    Government? state,
    String? area,
    String? phone,
    Stage? stage,
    Grade? grade,
    StudyType? studyType,
    String? parentPhone,
    List<int>? enrolledCoursesIDs,
    int? enrolledCoursesCount,
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
      area: area ?? this.area,
      phone: phone ?? this.phone,
      stage: stage ?? this.stage,
      grade: grade ?? this.grade,
      studyType: studyType ?? this.studyType,
      parentPhone: parentPhone ?? this.parentPhone,
      enrolledCoursesIDs: enrolledCoursesIDs ?? this.enrolledCoursesIDs,
      enrolledCoursesCount: enrolledCoursesCount ?? this.enrolledCoursesCount,
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
      'area': area,
      'phone': phone,
      'stage': stage.name,
      'grade': grade.name,
      'studyType': studyType.name,
      'parentPhone': parentPhone,
      'emailVerified': emailVerified,
      'photoURL': photoURL,
      'enrolledCourses': enrolledCoursesIDs,
      'enrolledCoursesCount': enrolledCoursesCount,
      'takenExamsCount': takenExamsCount,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final genderString = (map['gender'] ?? '').toString();
    final stateString = (map['state'] ?? '').toString();
    final gradeString = (map['grade'] ?? '').toString();
    final stageString = (map['stage'] ?? '').toString();
    final studyTypeString = (map['studyType'] ?? '').toString();

    return AppUser(
      userID: map['userID'] ?? '0000000',
      userName: map['userName'] ?? 'UnKnow',
      email: map['email'] ?? 'unknown@mrmichaelashrafdashboard.com',
      emailVerified: map['emailVerified'] ?? false,
      photoURL: map['photoURL'] ?? AppAssets.images.defaultAvatar,

      gender: Gender.values.firstWhere(
        (e) => e.name == genderString,
        orElse: () => GenderLabel.fromLabel(genderString) ?? Gender.male,
      ),

      state: Government.values.firstWhere(
        (e) => e.name == stateString,
        orElse: () => GovernmentX.fromLabel(stateString) ?? Government.cairo,
      ),

      area: map['area'] ?? 'Unknown Area',

      phone: map['phone'] ?? '01200000000',

      grade: Grade.values.firstWhere(
        (e) => e.name == gradeString,
        orElse: () => Grade.values.firstWhere(
          (g) => g.label == gradeString,
          orElse: () => Grade.allGrades,
        ),
      ),

      stage: Stage.values.firstWhere(
        (e) => e.name == stageString,
        orElse: () => Stage.values.firstWhere(
          (s) => s.label == stageString,
          orElse: () => Stage.highSchool,
        ),
      ),

      studyType: StudyType.values.firstWhere(
        (e) => e.name == studyTypeString,
        orElse: () =>
            StudyTypeLabel.fromLabel(studyTypeString) ??
            StudyType.onlineStudent,
      ),

      parentPhone: map['parentPhone'] ?? '01000000000',

      enrolledCoursesIDs: (map['enrolledCourses'] is Iterable)
          ? (map['enrolledCourses'] as Iterable)
                .map(
                  (e) => e is num
                      ? e.toInt()
                      : (e is String ? int.tryParse(e) : null),
                )
                .whereType<int>()
                .toList()
          : const [],

      enrolledCoursesCount: (map['enrolledCoursesCount'] as num?)?.toInt() ?? 0,
      takenExamsCount: (map['takenExamsCount'] as num?)?.toInt() ?? 0,
    );
  }

  factory AppUser.fromJson(String source) =>
      AppUser.fromMap(Map<String, dynamic>.from(jsonDecode(source)));

  String toJson() => jsonEncode(toMap());

  String get setProfileIcon => _setProfilePicture(gender);
}
