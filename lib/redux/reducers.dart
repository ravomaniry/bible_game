import 'package:bible_game/model/calculator_state.dart';
import 'package:bible_game/redux/actions.dart';

AppState mainReducer(AppState state, action) {
  if (action is InputAction) {
    return state.copy()..handleInput(action.value);
  }
  return state;
}
