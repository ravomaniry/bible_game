class DbState {
  final bool isReady;
  final double status;

  const DbState({
    this.isReady = false,
    this.status = 0,
  });

  DbState copyWith({
    bool isReady,
    double status,
  }) {
    return DbState(
      isReady: isReady ?? this.isReady,
      status: status ?? this.status,
    );
  }
}
