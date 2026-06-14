import 'dart:convert';

class Question {
  final String questionID;
  final String question;
  final double mark;
  final List<String>? options;
  final String correctAnswer;

  const Question({
    required this.questionID,
    required this.question,
    required this.mark,
    this.options,
    required this.correctAnswer,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionID': questionID,
      'question': question,
      'mark': mark,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionID: map['questionID'] ?? '',
      question: map['question'] ?? '',
      mark: (map['mark'] ?? 0).toDouble(),
      options:
          map['options'] != null ? List<String>.from(map['options']) : null,
      correctAnswer: map['correctAnswer'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Question.fromJson(String source) =>
      Question.fromMap(json.decode(source));
}
