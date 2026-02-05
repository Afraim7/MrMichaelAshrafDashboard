import 'dart:convert';
import 'package:mrmichaelashrafdashboard/Core/Enums/grade.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/subject.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/study_type.dart';
import '../../../Exams/Data/Models/lesson.dart';

class Course {
  final String courseID;
  final String? background;
  final String title;
  final String description;
  final String teacher;
  final List<String> content;
  final DateTime startDate;
  final DateTime? endDate;
  final int durationDays;
  final double discount;
  final int discountDueDate;
  final double priceForOnline;
  final double priceForCenter;
  final int enrollmentCount;
  final Grade grade;
  final Subject subject;
  final List<Lesson> lessons;
  final List<Map<String, dynamic>> comments;

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
    required this.discount,
    required this.discountDueDate,
    required this.priceForOnline,
    required this.priceForCenter,
    this.enrollmentCount = 0,
    this.grade = Grade.allGrades,
    required this.subject,
    this.lessons = const [],
    this.comments = const [],
  });

  // bool get isFree => (price ?? 0) == 0; // Deprecated: Need to know user type
  // Price Calculation Logic
  double getOriginalPrice(StudyType userType) {
    switch (userType) {
      case StudyType.onlineStudent:
        return priceForOnline;
      case StudyType.centerStudent:
        return priceForCenter;
    }
  }

  double getFinalPrice(StudyType userType) {
    double basePrice = getOriginalPrice(userType);

    // Check if discount is active based on date (assuming discountDueDate is Timestamp milliseconds)
    bool isDiscountActive = false;
    if (discountDueDate > 0) {
      final now = DateTime.now();
      final dueDate = DateTime.fromMillisecondsSinceEpoch(discountDueDate);
      if (now.isBefore(dueDate)) {
        isDiscountActive = true;
      }
    } else {
      // If no date set but discount > 0, maybe it's always active?
      // Or assume 0 means no due date limit?
      // User didn't specify. Assuming if due date is 0 it's always active if discount > 0
      if (discount > 0) isDiscountActive = true;
    }

    if (isDiscountActive) {
      // Discount is treated as a percentage (e.g., 20 means 20% off)
      double discountPercentage = discount;

      // Ensure percentage is reasonable (0-100)
      if (discountPercentage < 0) discountPercentage = 0;
      if (discountPercentage > 100) discountPercentage = 100;

      double finalPrice = basePrice - (basePrice * (discountPercentage / 100));
      return finalPrice < 0 ? 0 : finalPrice;
    }

    return basePrice;
  }

  bool hasDiscount(StudyType userType) {
    return getFinalPrice(userType) < getOriginalPrice(userType);
  }

  bool get isEverGreen => endDate == null;

  bool isActive(DateTime now) =>
      !now.isBefore(startDate) && (endDate == null || !now.isAfter(endDate!));

  int get totalLessons => lessons.length;

  Map<String, dynamic> toMap() {
    return {
      'courseID': courseID,
      'background': background,
      'title': title,
      'description': description,
      'teacher': teacher,
      'content': content,
      'startDate': startDate
          .toIso8601String(), // Changed to String as per request
      'endDate': endDate?.toIso8601String(), // Changed to String as per request
      'durationDays': durationDays,
      'discount': discount,
      'discountDueDate': discountDueDate,
      'priceForOnline': priceForOnline,
      'priceForCenter': priceForCenter,
      'enrollmentCount': enrollmentCount,
      'grade': grade.name,
      'subject': subject.name,
      'lessons': lessons.map((l) => l.toMap()).toList(),
      'comments': comments,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseID: map['courseID'] ?? '',
      background: map['background'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      teacher: map['teacher'] ?? '',
      content: List<String>.from(map['content'] ?? []),
      startDate: map['startDate'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['startDate'])
          : DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null
          ? (map['endDate'] is int
                ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
                : DateTime.parse(map['endDate']))
          : null,
      durationDays: map['durationDays'] ?? 0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      discountDueDate: map['discountDueDate'] ?? 0,
      priceForOnline: (map['priceForOnline'] as num?)?.toDouble() ?? 0.0,
      priceForCenter: (map['priceForCenter'] as num?)?.toDouble() ?? 0.0,
      enrollmentCount: map['enrollmentCount'] ?? 0,
      grade: Grade.values.firstWhere(
        (g) => g.name == map['grade'],
        orElse: () => Grade.allGrades,
      ),
      subject: Subject.values.firstWhere(
        (s) => s.name == map['subject'],
        orElse: () => Subject.geography,
      ),
      lessons: map['lessons'] != null
          ? List<Lesson>.from(map['lessons'].map((x) => Lesson.fromMap(x)))
          : [],
      comments: map['comments'] != null
          ? List<Map<String, dynamic>>.from(map['comments'])
          : [],
    );
  }

  String toJson() => json.encode(toMap());
  factory Course.fromJson(String source) => Course.fromMap(json.decode(source));
}
