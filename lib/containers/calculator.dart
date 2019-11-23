import 'package:bible_game/model/calculator_state.dart';
import 'package:bible_game/redux/actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';

class CalculatorViewModel {
  final String output;
  final String operator;
  final String mode;
  final double a;
  final double b;
  final Function(String) handleInput;

  CalculatorViewModel({
    @required this.output,
    @required this.operator,
    @required this.mode,
    @required this.a,
    @required this.b,
    @required this.handleInput,
  });

  factory CalculatorViewModel.create(Store<AppState> store) {
    return CalculatorViewModel(
      output: store.state.output,
      operator: store.state.operator,
      mode: store.state.mode,
      a: store.state.a,
      b: store.state.b,
      handleInput: (String value) {
        store.dispatch(InputAction(value: value));
      },
    );
  }
}
