import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/redux/state.dart';

MazeState mazeReducer(MazeState state, action) {
  if (action is UpdateMazeState) {
    return action.payload;
  }
  return state;
}
