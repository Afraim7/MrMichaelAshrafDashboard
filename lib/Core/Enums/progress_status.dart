enum ProgressStatus {
  notStarted,
  inProgress,
  completed,
  locked,
}

extension ProgressStatusX on ProgressStatus {
  static List<ProgressStatus> getAllStatuses() => ProgressStatus.values;
}


