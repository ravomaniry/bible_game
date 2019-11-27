import 'package:bible_game/redux/explorer/actions.dart';
import 'package:bible_game/redux/explorer/state.dart';

ExplorerState explorerReducer(ExplorerState state, action) {
  if (action is ReceiveExplorerBooksList) {
    return state.copyWith(books: action.payload, activeBook: state.activeBook);
  } else if (action is ExplorerSetActiveBook) {
    return state.copyWith(activeBook: action.payload);
  } else if (action is ExplorerReceiveVerses) {
    return state.copyWith(verses: action.payload, activeBook: state.activeBook);
  }
  return state;
}
