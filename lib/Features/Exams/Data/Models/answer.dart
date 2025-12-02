import 'package:mrmichaelashrafdashboard/Core/Enums/answer_status.dart';

class Answer {
  final String questionId;
  final String? studentAnswer;
  final AnswerStatus status;

  const Answer({
    required this.questionId,
    this.studentAnswer,
    required this.status,
  });

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      questionId: map['questionId'] ?? '',
      studentAnswer: map['studentAnswer'],
      status: AnswerStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AnswerStatus.unanswered,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'studentAnswer': studentAnswer,
      'status': status.name,
    };
  }
}
