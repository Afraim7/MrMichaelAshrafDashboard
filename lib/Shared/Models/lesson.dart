import 'dart:convert';

class Lesson {
  final String lessonID;
  final String? videoURL;
  final String title;
  final int? duration; // in seconds so we can sum up all lessons to know the whole course duration 
  final bool isWatched;
  final double watchedPercentage;
  final bool isLocked;
  final String? pdfURL; // Google Drive link to the PDF file
  final bool isPdfOpened; // Track if user opened the PDF

  Lesson({
    required this.lessonID,
    this.videoURL,
    required this.title,
    this.duration,
    this.isWatched = false,
    this.watchedPercentage = 0.0,
    this.isLocked = false,
    this.pdfURL,
    this.isPdfOpened = false,
  });

  Lesson copyWith({
    String? lessonID,
    String? courseID,
    String? videoURL,
    String? videoId,
    String? title,
    int? duration,
    bool? isWatched,
    double? watchedPercentage,
    bool? isLocked,
    String? pdfURL,
    bool? isPdfOpened,
  }) {
    return Lesson(
      lessonID: lessonID ?? this.lessonID,
      videoURL: videoURL ?? this.videoURL,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      isWatched: isWatched ?? this.isWatched,
      watchedPercentage: watchedPercentage ?? this.watchedPercentage,
      isLocked: isLocked ?? this.isLocked,
      pdfURL: pdfURL ?? this.pdfURL,
      isPdfOpened: isPdfOpened ?? this.isPdfOpened,
    );
  }


  /// toMap
  Map<String, dynamic> toMap() {
    return {
      'lessonID': lessonID,
      'videoURL': videoURL,
      'title': title,
      'duration': duration,
      'isWatched': isWatched,
      'watchedPercentage': watchedPercentage,
      'isLocked': isLocked,
      'pdfURL': pdfURL,
      'isPdfOpened': isPdfOpened,
    };
  }

  /// fromMap
  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      lessonID: map['lessonID'] ?? '',
      videoURL: map['videoURL'] ?? '',
      title: map['title'] ?? '',
      duration: map['duration'] != null ? (map['duration'] as num).toInt() : null,
      isWatched: map['isWatched'] ?? false,
      watchedPercentage: (map['watchedPercentage'] ?? 0.0).toDouble(),
      isLocked: map['isLocked'] ?? false,
      pdfURL: map['pdfURL'],
      isPdfOpened: map['isPdfOpened'] ?? false,
    );
  }

  /// toJson
  String toJson() => json.encode(toMap());

  /// fromJson
  factory Lesson.fromJson(String source) => Lesson.fromMap(json.decode(source));
}
