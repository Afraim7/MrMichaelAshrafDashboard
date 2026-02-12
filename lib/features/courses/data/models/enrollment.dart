import 'dart:convert';

enum EnrollmentStatus { pending, active, expired, cancelled }

class Enrollment {
  final String enrollmentID;
  final String userID;
  final String courseID;
  final String? paymentID;
  final EnrollmentStatus status;
  final DateTime enrolledAt;
  final DateTime? expiresAt;
  final double progress; // 0.0 - 1.0
  final DateTime? completedAt; 
  final String? lastWatchedLessonID; // optional quick resume

  Enrollment({
    required this.enrollmentID,
    required this.userID,
    required this.courseID,
    required this.status,
    required this.enrolledAt,
    this.expiresAt,
    this.paymentID,
    this.completedAt,
    this.lastWatchedLessonID,
    this.progress = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'enrollmentID': enrollmentID,
      'userID': userID,
      'courseID': courseID,
      'paymentID': paymentID,
      'status': status.name,
      'enrolledAt': enrolledAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
      'progress': progress,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'lastWatchedLessonID': lastWatchedLessonID,
    };
  }

  factory Enrollment.fromMap(Map<String, dynamic> map) {
    return Enrollment(
      enrollmentID: map['enrollmentID'] ?? '',
      userID: map['userID'] ?? '',
      courseID: map['courseID'] ?? '',
      paymentID: map['paymentID'],
      status: EnrollmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EnrollmentStatus.pending,
      ),
      enrolledAt: DateTime.fromMillisecondsSinceEpoch(map['enrolledAt']),
      expiresAt: map['expiresAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['expiresAt']) : null,
      progress: (map['progress'] ?? 0.0).toDouble(),
      completedAt: map['completedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['completedAt']) : null,
      lastWatchedLessonID: map['lastWatchedLessonID'],
    );
  }

  bool get isEnrolled => status.name == 'active';

  String toJson() => json.encode(toMap());

  factory Enrollment.fromJson(String source) => Enrollment.fromMap(json.decode(source));
}
