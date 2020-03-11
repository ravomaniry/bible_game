import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/redux/state.dart';
import 'package:redux_thunk/redux_thunk.dart';

class UpdateMazeState {
  final MazeState payload;

  UpdateMazeState(this.payload);
}

ThunkAction<AppState> invalidateNewlyRevealed() {
  return (store) {
    store.dispatch(UpdateMazeState(store.state.maze.copyWith(
      newlyRevealed: [],
    )));
  };
}
