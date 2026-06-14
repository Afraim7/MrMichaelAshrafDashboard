import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/answer.dart';

class ExamResult {
  final String? resultID;
  final String studentID;
  final String examID;
  final int? correctAnswers;
  final int? wrongAnswers;
  final double? totalMarks;
  final double? score;
  final DateTime? submittedAt;
  final List<Answer>? answers;
  final int? leftTrials;

  const ExamResult({
    this.resultID,
    required this.studentID,
    required this.examID,
    this.correctAnswers,
    this.wrongAnswers,
    this.totalMarks,
    this.score,
    this.submittedAt,
    this.answers,
    this.leftTrials,
  });

  ExamResult copyWith({
    String? resultID,
    String? studentID,
    String? examID,
    int? correctAnswers,
    int? wrongAnswers,
    double? totalMarks,
    double? score,
    DateTime? submittedAt,
    List<Answer>? answers,
    int? leftTrials,
  }) {
    return ExamResult(
      resultID: resultID ?? this.resultID,
      studentID: studentID ?? this.studentID,
      examID: examID ?? this.examID,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      totalMarks: totalMarks ?? this.totalMarks,
      score: score ?? this.score,
      submittedAt: submittedAt ?? this.submittedAt,
      answers: answers ?? this.answers,
      leftTrials: leftTrials ?? this.leftTrials,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'resultID': resultID,
      'studentID': studentID,
      'examID': examID,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'totalMarks': totalMarks,
      'score': score,
      'submittedAt': submittedAt?.toIso8601String(),
      'answers': answers?.map((a) => a.toMap()).toList(),
      'leftTrials': leftTrials,
    };
  }

  factory ExamResult.fromMap(Map<String, dynamic> map) {
    return ExamResult(
      resultID: map['resultID'],
      studentID: map['studentID'] ?? '',
      examID: map['examID'] ?? '',
      correctAnswers: map['correctAnswers'],
      wrongAnswers: map['wrongAnswers'],
      totalMarks: (map['totalMarks'] ?? 0).toDouble(),
      score: (map['score'] ?? 0).toDouble(),
      submittedAt: _parseDateTime(map['submittedAt']),
      answers:
          map['answers'] != null
              ? List<Answer>.from(
                (map['answers'] as List).map(
                  (a) => Answer.fromMap(Map<String, dynamic>.from(a)),
                ),
              )
              : null,
      leftTrials: (map['leftTrials'] as num?)?.toInt(),
    );
  }

  /// Tolerant date parser — handles Firestore [Timestamp] (server value),
  /// epoch millis, and ISO strings.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String toJson() => json.encode(toMap());

  factory ExamResult.fromJson(String source) =>
      ExamResult.fromMap(json.decode(source));
}
