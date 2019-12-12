import 'package:bible_game/redux/games/actions.dart';
import 'package:bible_game/redux/games/state.dart';

GamesState gamesListStateReducer(GamesState state, action) {
  if (action is ReceiveGamesList) {
    return state.copyWith(list: action.payload);
  } else if (action is ReceiveBooksList) {
    return state.copyWith(books: action.payload);
  } else if (action is ToggleGamesEditorDialog) {
    return _toggleAndResetDialogA(state);
  } else if (action is UpdateGameVerse) {
    return state.copyWith(verse: action.payload);
  }
  return state;
}

GamesState _toggleAndResetDialogA(GamesState state) {
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
