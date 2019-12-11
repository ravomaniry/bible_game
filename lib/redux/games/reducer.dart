import 'package:bible_game/redux/games/actions.dart';
import 'package:bible_game/redux/games/state.dart';

GamesListState gamesListStateReducer(GamesListState state, action) {
  if (action is ReceiveGamesList) {
    return state.copyWith(list: action.payload);
  } else if (action is ReceiveBooksList) {
    return state.copyWith(books: action.payload);
  } else if (action is ToggleGamesEditorDialog) {
    return _toggleAndResetDialogA(state);
  }
  return state;
}

GamesListState _toggleAndResetDialogA(GamesListState state) {
  return state.copyWith(
    dialogIsOpen: !state.dialogIsOpen,
    startBook: -1,
    startChapter: -1,
    startVerse: -1,
    endBook: -1,
    endChapter: -1,
    endVerse: -1,
  );
}
