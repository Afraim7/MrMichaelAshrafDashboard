class CourseComment {
  final String commentID;
  final String userID;
  final String userDisplayName;
  final String text;
  final DateTime date;
  final double? stars;

  CourseComment({
    required this.commentID,
    required this.userID,
    required this.userDisplayName,
    required this.text,
    required this.date,
    this.stars,
  });

  Map<String, dynamic> toMap() {
    return {
      'commentID': commentID,
      'userID': userID,
      'userDisplayName': userDisplayName,
      'text': text,
      'date': date.millisecondsSinceEpoch,
      'stars': stars,
    };
  }

  factory CourseComment.fromMap(Map<String, dynamic> map) {
    return CourseComment(
      commentID: map['commentID'] ?? '',
      userID: map['userID'] ?? '',
      userDisplayName: map['userDisplayName'] ?? 'مستخدم غير معروف',
      text: map['text'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      stars: (map['stars'] as num?)?.toDouble(),
    );
  }
}
