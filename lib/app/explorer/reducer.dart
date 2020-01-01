import 'package:bible_game/app/explorer/actions.dart';
import 'package:bible_game/app/explorer/state.dart';

ExplorerState explorerReducer(ExplorerState state, action) {
  if (action is UpdateExplorerState) {
    return action.payload;
  }
  return state;
}
