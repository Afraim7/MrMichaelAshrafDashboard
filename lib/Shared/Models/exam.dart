import 'dart:convert';
import 'package:mrmichaelashrafdashboard/Core/Config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/exam_status.dart';
import 'package:mrmichaelashrafdashboard/Shared/Models/question.dart';

class Exam {
  final String id;
  final String? courseID;
  final String title;
  final String? description;
  final ExamStatus? state;
  final String grade;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? duration;
  final List<Question>? questions;

  const Exam({
    required this.id,
    this.courseID,
    required this.title,
    this.description,
    this.state,
    required this.grade,
    this.startTime,
    this.endTime,
    this.duration,
    this.questions,
  });

  Exam copyWith({
    String? id,
    String? courseID,
    String? title,
    String? description,
    ExamStatus? state,
    String? grade,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    List<Question>? questions,
  }) {
    return Exam(
      id: id ?? this.id,
      courseID: courseID ?? this.courseID,
      title: title ?? this.title,
      description: description ?? this.description,
      state: state ?? this.state,
      grade: grade ?? this.grade,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      questions: questions ?? this.questions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseID': courseID,
      'title': title,
      'description': description,
      'grade': grade,
      'startTime': startTime?.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'duration': duration,
      'questions': questions?.map((q) => q.toMap()).toList(),
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

    return Exam(
      id: map['id'] ?? '',
      courseID: map['courseID'],
      title: map['title'] ?? '',
      description: map['description'],
      state: state,
      grade: map['grade'] ?? '',
      startTime: map['startTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startTime'])
          : null,
      endTime: map['endTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'])
          : null,
      duration: map['duration'] != null ? map['duration'] as int : null,
      questions: map['questions'] != null
          ? List<Question>.from(
              (map['questions'] as List).map(
                (q) => Question.fromMap(Map<String, dynamic>.from(q)),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Exam.fromJson(String source) => Exam.fromMap(json.decode(source));

  double fullExamMark() {
    if (questions == null || questions!.isEmpty) return 0.0;
    return questions!.fold(0.0, (sum, q) => sum + q.mark);
  }

  ExamStatus computeStudentExamState({bool hasResult = false}) {
    final now = DateTime.now();
    if (hasResult) return ExamStatus.completed;

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

  ExamStatus computeAdminExamState() {
    final now = DateTime.now();

    if (startTime == null || endTime == null) {
      return ExamStatus.upcoming;
    }

    if (now.isBefore(startTime!)) {
      return ExamStatus.upcoming;
    }

    if (now.isAfter(endTime!)) {
      return ExamStatus.done;
    }

    return ExamStatus.active;
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
