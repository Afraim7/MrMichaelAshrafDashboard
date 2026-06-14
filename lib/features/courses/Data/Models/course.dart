import 'dart:convert';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/subject.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course_comment.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course_lesson.dart';

class Course {
  final String courseID;
  final String? background;
  final String title;
  final String description;
  final String teacher;
  final List<String> content;
  final double discount;
  final int discountDueDate;
  final double price;
  final int enrollmentCount;
  final Grade grade;
  final Subject subject;
  final List<CourseLesson> lessons;
  final List<CourseComment> comments;
  final bool isVisible;

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
    required this.discount,
    required this.discountDueDate,
    required this.price,
    this.enrollmentCount = 0,
    this.grade = Grade.allGrades,
    required this.subject,
    this.lessons = const [],
    this.comments = const [],
    this.isVisible = true,
  });

  // Price Calculation Logic
  double getOriginalPrice() {
    return price;
  }

  double getFinalPrice() {
    double basePrice = getOriginalPrice();

    // 1. Check if discount is applicable
    if (!hasDiscount()) {
      return basePrice;
    }

    // 2. Calculate Percentage Discount
    // discount is now 0-100 representing percentage
    double discountAmount = basePrice * (discount / 100);
    double finalPrice = basePrice - discountAmount;

    return finalPrice < 0 ? 0 : finalPrice;
  }

  bool hasDiscount() {
    if (discount <= 0) return false;

    // Check Expiry
    if (discountDueDate > 0) {
      final now = DateTime.now();
      final dueDate = DateTime.fromMillisecondsSinceEpoch(discountDueDate);
      if (now.isAfter(dueDate)) {
        return false; // Expired
      }
    }

    return true;
  }

  /// Discount percentage as a whole number (e.g. 25 for 25%).
  int get discountPercent => discount.round();

  /// Time remaining on the discount, or null if there's no live, dated
  /// discount. Drives the "ينتهي العرض خلال…" urgency chip.
  Duration? discountTimeLeft() {
    if (!hasDiscount() || discountDueDate <= 0) return null;
    final due = DateTime.fromMillisecondsSinceEpoch(discountDueDate);
    final left = due.difference(DateTime.now());
    return left.isNegative ? null : left;
  }

  int get totalLessons => lessons.length;

  Map<String, dynamic> toMap() {
    return {
      'courseID': courseID,
      'background': background,
      'title': title,
      'description': description,
      'teacher': teacher,
      'content': content,
      'discount': discount,
      'discountDueDate': discountDueDate,
      'price': price,
      'enrollmentCount': enrollmentCount,
      'grade': grade.name,
      'subject': subject.name,
      'lessons': lessons.map((l) => l.toMap()).toList(),
      'comments': comments.map((c) => c.toMap()).toList(),
      'isVisible': isVisible,
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
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      discountDueDate: map['discountDueDate'] ?? 0,
      price:
          (map['price'] as num?)?.toDouble() ??
          0.0, // Changed to single price field
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
          ? List<CourseLesson>.from(
              (map['lessons'] as List).map((x) => CourseLesson.fromMap(x)),
            )
          : [],
      comments: map['comments'] != null
          ? List<CourseComment>.from(
              map['comments'].map((x) => CourseComment.fromMap(x)),
            )
          : [],
      isVisible: map['isVisible'] as bool? ?? true,
    );
  }

  String toJson() => json.encode(toMap());
  factory Course.fromJson(String source) => Course.fromMap(json.decode(source));
}
