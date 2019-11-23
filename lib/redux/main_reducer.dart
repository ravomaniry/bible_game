import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/calculator/reducer.dart';

AppState mainReducer(AppState state, action) {
  return AppState(
    calculator: calculatorReducer(state.calculator, action),
  );
}
