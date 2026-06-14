import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/enums/gender.dart';
import 'package:mrmichaelashrafdashboard/core/enums/government.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/stage.dart';
import 'package:mrmichaelashrafdashboard/core/enums/study_type.dart';

class AppUser extends Equatable {
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
  final bool? emailVerified; // once email is verified - right after creation
  final String photoURL; // static images path will be passed based on gender

  // will be calculated later
  final List<String> enrolledCoursesIDs;
  final List<String> takenExamsIDs;

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
    this.takenExamsIDs = const [],
  }) : photoURL = photoURL ?? _setProfilePicture(gender);

  static String _setProfilePicture(Gender gender) {
    return (gender == Gender.male)
        ? AppAssets.images.maleUser
        : (gender == Gender.female)
        ? AppAssets.images.femaleUser
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
    List<String>? enrolledCoursesIDs,
    List<String>? takenExamsIDs,
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
      takenExamsIDs: takenExamsIDs ?? this.takenExamsIDs,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> map) {
    final genderString = (map['gender'] ?? '').toString();
    final stateString = (map['state'] ?? '').toString();
    final gradeString = (map['grade'] ?? '').toString();
    final stageString = (map['stage'] ?? '').toString();
    final studyTypeString = (map['studyType'] ?? '').toString();

    return AppUser(
      userID: map['userID'] ?? '0000000',
      userName: map['userName'] ?? 'UnKnow',
      email: map['email'] ?? 'unknown@mrmichaelashraf.com',
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
                .map((e) => e.toString())
                .toList()
          : const [],

      takenExamsIDs: (map['takenExams'] as List?)?.cast<String>() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
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
      'takenExams': takenExamsIDs,
    };
  }

  String get setProfileIcon => _setProfilePicture(gender);

  String get enrolledCoursesCount => enrolledCoursesIDs.length.toString();

  String get takenExamsCount => takenExamsIDs.length.toString();

  factory AppUser.fromString(String userJson) =>
      AppUser.fromJson(const JsonDecoder().convert(userJson));

  @override
  String toString() => const JsonEncoder().convert(toJson());

  factory AppUser.empty() {
    return AppUser(
      userID: 'userID',
      userName: 'Unknow',
      email: 'unknow@gmail.com',
      gender: Gender.male,
      state: Government.cairo,
      area: '',
      phone: '0120000000000',
      stage: Stage.highSchool,
      grade: Grade.allGrades,
      studyType: StudyType.onlineStudent,
      parentPhone: '01200000000',
    );
  }

  @override
  List<Object?> get props => [
    userID,
    userName,
    email,
    gender,
    state,
    area,
    phone,
    stage,
    grade,
    studyType,
    parentPhone,
    emailVerified,
    photoURL,
    enrolledCoursesIDs,
    takenExamsIDs,
  ];
}
