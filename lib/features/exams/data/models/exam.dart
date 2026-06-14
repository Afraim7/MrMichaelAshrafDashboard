import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/exam_status.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/question.dart';

class Exam {
  final String examID;
  final String title;
  final String? description;
  final ExamStatus? state;
  final Grade grade;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? duration;
  final List<Question>? questions;
  final int? maxTrials;
  final bool isVisible;

  const Exam({
    required this.examID,
    required this.title,
    this.description,
    this.state,
    this.grade = Grade.allGrades,
    this.startTime,
    this.endTime,
    this.duration,
    this.questions,
    this.maxTrials,
    this.isVisible = true,
  });

  Exam copyWith({
    String? examID,
    String? courseID,
    String? title,
    String? description,
    ExamStatus? state,
    Grade? grade,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    List<Question>? questions,
    int? maxTrials,
    bool? isVisible,
  }) {
    return Exam(
      examID: examID ?? this.examID,
      title: title ?? this.title,
      description: description ?? this.description,
      state: state ?? this.state,
      grade: grade ?? this.grade,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      questions: questions ?? this.questions,
      maxTrials: maxTrials ?? this.maxTrials,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': examID,
      'title': title,
      'description': description,
      'grade': grade.name,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration,
      'questions': questions?.map((q) => q.toMap()).toList(),
      'maxTrials': maxTrials,
      'isVisible': isVisible,
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map) {
    ExamStatus? state;
    if (map['state'] != null) {
      try {
        state = ExamStatus.values.firstWhere(
          (e) => e.name == map['state'],
          orElse: () => ExamStatus.upcoming,
        );
      } catch (_) {
        state = null;
      }
    }

    final examId = map['id'] ?? '';
    final rawQuestions = map['questions'] != null
        ? List<Question>.from(
            (map['questions'] as List).map(
              (q) => Question.fromMap(Map<String, dynamic>.from(q)),
            ),
          )
        : null;

    final normalizedQuestions = rawQuestions?.asMap().entries.map((entry) {
      final index = entry.key;
      final question = entry.value;
      if (question.questionID.isNotEmpty) return question;
      return Question(
        questionID: '${examId}_$index',
        question: question.question,
        mark: question.mark,
        options: question.options,
        correctAnswer: question.correctAnswer,
      );
    }).toList();

    return Exam(
      examID: examId,
      title: map['title'] ?? '',
      description: map['description'],
      state: state,
      grade: Grade.values.firstWhere(
        (g) => g.name == map['grade'],
        orElse: () => Grade.allGrades,
      ),
      startTime: _parseDateTime(map['startTime']),
      endTime: _parseDateTime(map['endTime']),
      duration: map['duration'] != null ? map['duration'] as int : null,
      questions: normalizedQuestions,
      maxTrials: map['maxTrials'] as int?,
      isVisible: map['isVisible'] as bool? ?? true,
    );
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  String toJson() => json.encode(toMap());

  factory Exam.fromJson(String source) => Exam.fromMap(json.decode(source));

  double fullExamMark() {
    if (questions == null || questions!.isEmpty) return 0.0;
    return questions!.fold(0.0, (acc, q) => acc + q.mark);
  }

  /// Whether results (score + answer key) may be shown to the student.
  /// Sealed until the exam window closes; if there's no [endTime] the exam is
  /// a practice/open one, so results are visible immediately.
  bool resultsVisible() {
    if (endTime == null) return true;
    return DateTime.now().isAfter(endTime!);
  }

  /// Absolute moment the running exam must end, given when the student
  /// [startedAt]. It's the earlier of (start + duration) and the exam's
  /// [endTime]. Returns null for an untimed exam (no duration, no endTime).
  ///
  /// This caps late-starters: start 11:55, end 12:00, duration 60 → 5 minutes.
  DateTime? effectiveDeadline(DateTime startedAt) {
    final byDuration = duration != null
        ? startedAt.add(Duration(minutes: duration!))
        : null;
    if (byDuration != null && endTime != null) {
      return byDuration.isBefore(endTime!) ? byDuration : endTime;
    }
    return byDuration ?? endTime;
  }

  ExamStatus computeUserExamState({bool hasResult = false}) {
    final now = DateTime.now();
    if (hasResult) {
      // Submitted: hold the result back until the window closes.
      return resultsVisible() ? ExamStatus.completed : ExamStatus.underReview;
    }

    if (startTime == null && endTime == null) return ExamStatus.upcoming;

    if (startTime != null && endTime != null) {
      if (now.isBefore(startTime!)) return ExamStatus.upcoming;
      if (now.isAfter(endTime!)) return ExamStatus.missed;
      return ExamStatus.active;
    }

    if (startTime != null && endTime == null) {
      if (now.isBefore(startTime!)) return ExamStatus.upcoming;
      return ExamStatus.active;
    }

    if (startTime == null && endTime != null) {
      if (now.isAfter(endTime!)) return ExamStatus.missed;
      return ExamStatus.active;
    }

    return ExamStatus.upcoming;
  }

  String examDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) {
      return AppStrings.emptyStates.noDate;
    }
    if (startDate != null && endDate != null) {
      return '${startDate.year}/${startDate.month}/${startDate.day} - ${endDate.year}/${endDate.month}/${endDate.day}';
    } else if (startDate != null) {
      return 'من ${startDate.year}/${startDate.month}/${startDate.day}';
    } else {
      return 'حتى ${endDate!.year}/${endDate.month}/${endDate.day}';
    }
  }

  bool isActive() {
    final now = DateTime.now();
    if (startTime == null || endTime == null) {
      return false;
    }
    return now.isAfter(startTime!) && now.isBefore(endTime!);
  }
}
