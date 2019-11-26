import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/words_in_word/state.dart';

WordsInWordState wordsInWordReducer(WordsInWordState state, action) {
  if (action is GoToAction) {
    if (action.payload == Routes.wordsInWord && state == null) {
      state = WordsInWordState.emptyState();
    }
  }
  return state;
}
