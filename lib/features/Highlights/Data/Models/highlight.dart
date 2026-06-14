import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/highlights_types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Highlight {
  final String id;
  final String message;
  final HighlightType type;
  final DateTime? startTime;
  final DateTime? endTime;
  final Grade grade;

  /// Admin-controlled visibility flag. When false, the highlight is hidden
  /// from students regardless of its time window.
  final bool isVisible;

  Highlight({
    this.id = '',
    required this.message,
    required this.type,
    this.startTime,
    this.endTime,
    this.grade = Grade.allGrades,
    this.isVisible = true,
  });

  Highlight copyWith({
    String? id,
    String? message,
    HighlightType? type,
    DateTime? startTime,
    DateTime? endTime,
    Grade? grade,
    bool? isVisible,
  }) {
    return Highlight(
      id: id ?? this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      grade: grade ?? this.grade,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'type': type.name,
      'startDate': startTime?.toIso8601String(),
      'endDate': endTime?.toIso8601String(),
      'grade': grade.name,
      'isVisible': isVisible,
    };
  }

  factory Highlight.fromJson(Map<String, dynamic> map, {String id = ''}) {
    return Highlight(
      id: id,
      message: map['message'] ?? '',
      type: HighlightType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => HighlightType.quote,
      ),
      startTime:
          map['startDate'] is String
              ? DateTime.tryParse(map['startDate'])
              : (map['startDate'] != null
                  ? (map['startDate'] as Timestamp).toDate()
                  : null),
      endTime:
          map['endDate'] is String
              ? DateTime.tryParse(map['endDate'])
              : (map['endDate'] != null
                  ? (map['endDate'] as Timestamp).toDate()
                  : null),
      grade:
          map['grade'] != null
              ? Grade.values.firstWhere(
                (e) => e.name == map['grade'],
                orElse: () => Grade.allGrades,
              )
              : Grade.allGrades,
      isVisible: map['isVisible'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'Highlight(id: $id, message: $message, type: ${type.name}, startTime: $startTime, endTime: $endTime, grade: ${grade.name})';
  }

  bool isActive() {
    final now = DateTime.now();
    final start = startTime ?? DateTime(now.year, now.month, now.day, 0, 0, 0);
    final end = endTime ?? DateTime(now.year, now.month, now.day, 23, 59, 59);
    return !now.isBefore(start) && !now.isAfter(end);
  }
}
