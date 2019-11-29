import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:bible_game/redux/words_in_word/cells_action.dart';
import 'package:bible_game/redux/words_in_word/state.dart';

WordsInWordState wordsInWordReducer(WordsInWordState state, action) {
  if (action is UpdateWordsInWordState) {
    return action.payload;
  } else if (action is UpdateWordsInWordCells) {
    return state.copyWith(cells: action.payload);
  }
  return state;
}
