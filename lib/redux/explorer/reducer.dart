import 'package:bible_game/redux/explorer/actions.dart';
import 'package:bible_game/redux/explorer/state.dart';

ExplorerState explorerReducer(ExplorerState state, action) {
  if (action is ReceiveExplorerBooksList) {
    return state.copyWith(books: action.payload);
  }
  return state;
}
