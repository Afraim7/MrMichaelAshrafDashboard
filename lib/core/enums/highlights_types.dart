enum HighlightType {
  quote,
  studyFact,
  important,
  news,
  note,
  exam,
  revision
}

extension HighlightTypeX on HighlightType {
  String get label {
    switch (this) {
      case HighlightType.quote:
        return 'اقتباس';
      case HighlightType.studyFact:
        return 'معلومة دراسية';
      case HighlightType.important:
        return 'تنبيه هام';
      case HighlightType.news:
        return 'خبر اليوم';
      case HighlightType.exam :
        return 'أمتحان';
      case HighlightType.note :
        return 'ملاحظة';
      case HighlightType.revision :
        return 'مراجعة';
    }
  }
}
