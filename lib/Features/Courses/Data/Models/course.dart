import 'dart:convert';
import 'package:mrmichaelashrafdashboard/Core/Enums/grade.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/subject.dart';
import '../../../Exams/Data/Models/lesson.dart';

class Course {
  final String courseID;
  final String? background;
  final String title;
  final String description;
  final String teacher;
  final List<String> content; // bullet points
  final DateTime startDate;
  final DateTime? endDate; // null = everGreen
  final int durationDays; // 0 = unlimited
  final double? price; // 0 means free course
  final int enrollmentCount; // how many students enrolled for this course
  final Grade grade; // اولي قانوي ولا تانيه ولا تالته
  final Subject subject; // تاريخ او جغرافيا
  final List<Lesson> lessons;

  //final List<Map<String, String>> comments;

  Course({
    required this.courseID,
    required this.title,
    this.background = const String.fromEnvironment(
      'DEFAULT_COURSE_BG',
      defaultValue: 'assets/images/course_placeholder.jpg',
    ),
    required this.teacher,
    required this.description,
    required this.content,
    required this.startDate,
    this.endDate,
    required this.durationDays,
    this.price,
    this.enrollmentCount = 0,
    this.grade = Grade.allGrades,
    required this.subject,
    this.lessons = const [],
  });

  bool get isFree => price == 0;
  bool get isEverGreen => endDate == null;
  bool isActive(DateTime now) =>
      (!now.isBefore(startDate)) && (endDate == null || !now.isAfter(endDate!));
  int get totalLessons => lessons.length;
  bool get isCompleted =>
      lessons.isNotEmpty && lessons.every((l) => l.isWatched);

  Map<String, dynamic> toMap() {
    return {
      'courseID': courseID,
      'background': background,
      'title': title,
      'description': description,
      'teacher': teacher,
      'content': content,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'durationDays': durationDays,
      'price': price ?? 0.0,
      'enrollmentCount': enrollmentCount,
      'grade': grade.name,
      'subject': subject.name,
      'lessons': lessons.map((l) => l.toMap()).toList(),
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseID: map['courseID'] ?? '',
      background: map['background'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      teacher: map['teacher'] ?? '',
      content: List<String>.from(map['content'] ?? []),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
          : null,
      durationDays: map['durationDays'] ?? 0,
      price: (map['price'] as num?)?.toDouble(),
      enrollmentCount: map['enrollmentCount'] ?? 0,
      grade: map['grade'] != null
          ? Grade.values.firstWhere(
              (g) => g.name == map['grade'],
              orElse: () => Grade.allGrades,
            )
          : Grade.allGrades,
      subject: map['subject'] != null
          ? Subject.values.firstWhere(
              (s) => s.name == map['subject'],
              orElse: () => Subject.geography,
            )
          : Subject.geography,
      lessons: map['lessons'] != null
          ? List<Lesson>.from(map['lessons'].map((x) => Lesson.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Course.fromJson(String source) => Course.fromMap(json.decode(source));
}
