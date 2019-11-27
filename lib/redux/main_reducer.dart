import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/calculator/reducer.dart';
import 'package:bible_game/redux/quit_single_game_dialog/reducer.dart';
import 'package:bible_game/redux/router/reducer.dart';
import 'package:bible_game/redux/words_in_word/reducer.dart';

AppState mainReducer(AppState state, action) {
  return AppState(
    dba: state.dba,
    calculator: calculatorReducer(state.calculator, action),
    route: routerReducer(state.route, action),
    wordsInWord: wordsInWordReducer(state.wordsInWord, action),
    quitSingleGameDialog: quitSingleGameDialogReducer(state.quitSingleGameDialog, action),
  );
}
