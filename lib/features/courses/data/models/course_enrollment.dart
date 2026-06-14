import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/core/enums/enrollment_status.dart';

class CourseEnrollment {
  final String enrollmentID;
  final String userID;
  final String courseID;
  final String? paymentID;
  final EnrollmentStatus status;
  final DateTime enrolledAt;
  final DateTime? completedAt;

  /// HEART OF THE SYSTEM
  /// {
  ///   lessonID: {
  ///     watchedPercentage,
  ///     lastSeconds,
  ///     isCompleted,
  ///     updatedAt
  ///   }
  /// }
  final Map<String, dynamic> progressMap;

  CourseEnrollment({
    required this.enrollmentID,
    required this.userID,
    required this.courseID,
    required this.status,
    required this.enrolledAt,
    this.paymentID,
    this.completedAt,
    Map<String, dynamic>? progressMap,
  }) : progressMap = progressMap ?? const {};

  Map<String, dynamic> toMap() {
    return {
      'enrollmentID': enrollmentID,
      'userID': userID,
      'courseID': courseID,
      'paymentID': paymentID,
      'status': status.name,
      'enrolledAt': enrolledAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'progressMap': progressMap,
    };
  }

  factory CourseEnrollment.fromMap(Map<String, dynamic> map) {
    return CourseEnrollment(
      enrollmentID: map['enrollmentID'] ?? '',
      userID: map['userID'] ?? '',
      courseID: map['courseID'] ?? '',
      paymentID: map['paymentID'],
      status: EnrollmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EnrollmentStatus.pending,
      ),
      enrolledAt: _parseDateTime(map['enrolledAt']) ?? DateTime.now(),
      completedAt: _parseDateTime(map['completedAt']),
      progressMap:
          map['progressMap'] != null
              ? Map<String, dynamic>.from(map['progressMap'])
              : {},
    );
  }

  bool get isEnrolled => status == EnrollmentStatus.active;
  bool get isReady => status == EnrollmentStatus.ready;

  String toJson() => json.encode(toMap());
  factory CourseEnrollment.fromJson(String source) =>
      CourseEnrollment.fromMap(json.decode(source));

  int getCompletedLessons() {
    int count = 0;
    for (final data in progressMap.values) {
      if (data is Map) {
        if ((data['watchedPercentage'] ?? 0.0) >= 0.95 ||
            data['isCompleted'] == true) {
          count++;
        }
      }
    }
    return count;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  double getCourseProgress(int totalLessons) {
    if (totalLessons == 0) return 0.0;
    return getCompletedLessons() / totalLessons;
  }

  bool isCourseCompleted(int totalLessons) =>
      totalLessons > 0 && getCompletedLessons() == totalLessons;

  double getLessonProgress(String lessonID) {
    final data = progressMap[lessonID];
    if (data is Map) {
      return (data['watchedPercentage'] as num?)?.toDouble() ?? 0.0;
    } else if (data is double) {
      return data;
    }
    return 0.0;
  }

  bool isLessonCompleted(String lessonID) {
    final data = progressMap[lessonID];
    if (data is Map) {
      return data['isCompleted'] == true || getLessonProgress(lessonID) >= 0.95;
    } else if (data is double) {
      return data >= 0.95;
    }
    return false;
  }
}
