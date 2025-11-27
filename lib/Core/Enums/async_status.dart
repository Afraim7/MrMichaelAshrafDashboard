enum AsyncStatus {
  idle,
  loading,
  success,
  error,
}

extension AsyncStatusX on AsyncStatus {
  static List<AsyncStatus> getAllAsyncStatuses() => AsyncStatus.values;
}


