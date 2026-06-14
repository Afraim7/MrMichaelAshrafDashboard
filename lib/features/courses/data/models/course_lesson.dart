import 'dart:convert';

class CourseLesson {
  final String lessonID;
  final String title;
  final String? videoURL;
  final int? duration; // in seconds to know whole course duration
  final String? pdfURL; // Google Drive link to the PDF file

  CourseLesson({
    required this.lessonID,
    this.videoURL,
    required this.title,
    this.duration,
    this.pdfURL,
  });

  CourseLesson copyWith({
    String? lessonID,
    String? videoURL,
    String? title,
    int? duration,
    String? pdfURL,
  }) {
    return CourseLesson(
      lessonID: lessonID ?? this.lessonID,
      videoURL: videoURL ?? this.videoURL,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      pdfURL: pdfURL ?? this.pdfURL,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonID': lessonID,
      'videoURL': videoURL,
      'title': title,
      'duration': duration,
      'pdfURL': pdfURL,
    };
  }

  factory CourseLesson.fromMap(Map<String, dynamic> map) {
    return CourseLesson(
      lessonID: map['lessonID'] ?? '',
      videoURL: map['videoURL'] ?? '',
      title: map['title'] ?? '',
      duration:
          map['duration'] != null ? (map['duration'] as num).toInt() : null,
      pdfURL: map['pdfURL'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CourseLesson.fromJson(String source) =>
      CourseLesson.fromMap(json.decode(source));
}
