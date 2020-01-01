import 'package:bible_game/games/words_in_word/actions/action_creators.dart';
import 'package:bible_game/games/words_in_word/actions/cells_action.dart';
import 'package:bible_game/games/words_in_word/reducer/state.dart';

WordsInWordState wordsInWordReducer(WordsInWordState state, action) {
  if (action is UpdateWordsInWordState) {
    return action.payload;
  } else if (action is UpdateWordsInWordCells) {
    return state.copyWith(cells: action.payload);
  } else if (action is UpdatePropositionAnimation) {
    return state.copyWith(propositionAnimation: action.payload);
  }
  return state;
}
