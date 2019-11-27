import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/words_in_word/state.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';

class UpdateWordsInWordState {
  final WordsInWordState payload;

  UpdateWordsInWordState(this.payload);
}

final ThunkAction<AppState> goToWordsInWord = (Store<AppState> store) {
  store.dispatch(GoToAction(Routes.wordsInWord));
  store.dispatch(UpdateWordsInWordState(WordsInWordState(
    verse: null,
    cells: [],
    chars: [],
    selected: [],
  )));
};
