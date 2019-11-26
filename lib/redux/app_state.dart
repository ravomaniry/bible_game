import 'package:bible_game/redux/calculator/state.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/words_in_word/state.dart';

class AppState {
  Routes route;
  CalculatorState calculator;
  WordsInWordState wordsInWord;

  AppState({
    this.route = Routes.home,
    this.calculator,
    this.wordsInWord,
  });

  factory AppState.initialState() {
    return AppState();
  }
}
