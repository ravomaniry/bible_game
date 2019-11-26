import 'package:bible_game/redux/calculator/actions.dart';
import 'package:bible_game/redux/calculator/reducer_util.dart';
import 'package:bible_game/redux/calculator/state.dart';
import 'package:bible_game/redux/router/actions.dart';

CalculatorState calculatorReducer(CalculatorState state, action) {
  if (action is GoToAction) {
    state = state ?? CalculatorState();
  } else if (action is InputAction) {
    return handleInput(state.copy(), action.value);
  }
  return state;
}
