import 'package:bible_game/redux/calculator/state.dart';
import 'package:flutter/foundation.dart';

class AppState {
  CalculatorState calculator;

  AppState({@required this.calculator});

  factory AppState.initialState() {
    return AppState(
      calculator: CalculatorState(),
    );
  }
}
