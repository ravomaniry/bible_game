import 'package:bible_game/redux/games/actions.dart';
import 'package:bible_game/redux/games/state.dart';

GamesListState gamesListStateReducer(GamesListState state, action) {
  if (action is ReceiveGamesList) {
    return state.copyWith(list: action.payload);
  }
  return state;
}
