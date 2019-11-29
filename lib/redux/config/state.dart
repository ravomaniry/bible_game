class ConfigState {
  final double screenWidth;

  ConfigState({
    this.screenWidth = 0,
  });

  factory ConfigState.initialState() {
    return ConfigState();
  }

  ConfigState copyWith({double screenWidth}) {
    return ConfigState(
      screenWidth: screenWidth ?? this.screenWidth,
    );
  }
}
