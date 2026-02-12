import 'dart:convert';

class ExamResult {
  final String? id;
  final String studentId;
  final String examId;
  final double? score;
  final double? totalMarks;
  final DateTime? submittedAt;
  final List<Map<String, dynamic>>? answers;

  const ExamResult({
    this.id,
    required this.studentId,
    required this.examId,
    this.score,
    this.totalMarks,
    this.submittedAt,
    this.answers,
  });

  ExamResult copyWith({
    String? id,
    String? studentId,
    String? examId,
    double? score,
    double? totalMarks,
    DateTime? submittedAt,
    List<Map<String, dynamic>>? answers,
  }) {
    return ExamResult(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      examId: examId ?? this.examId,
      score: score ?? this.score,
      totalMarks: totalMarks ?? this.totalMarks,
      submittedAt: submittedAt ?? this.submittedAt,
      answers: answers ?? this.answers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'examId': examId,
      'score': score,
      'totalMarks': totalMarks,
      'submittedAt': submittedAt?.millisecondsSinceEpoch,
      'answers': answers,
    };
  }

  factory ExamResult.fromMap(Map<String, dynamic> map) {
    return ExamResult(
      id: map['id'],
      studentId: map['studentId'] ?? '',
      examId: map['examId'] ?? '',
      score: (map['score'] ?? 0).toDouble(),
      totalMarks: (map['totalMarks'] ?? 0).toDouble(),
      submittedAt: map['submittedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['submittedAt'])
          : null,
      answers: map['answers'] != null
          ? List<Map<String, dynamic>>.from(map['answers'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ExamResult.fromJson(String source) => ExamResult.fromMap(json.decode(source));
}
