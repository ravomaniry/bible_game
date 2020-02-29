import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/logic/paths.dart';
import 'package:bible_game/games/maze/logic/reveal.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> proposeMaze(List<Coordinate> cellCoordinates) {
  return (store) {
    final state = store.state.maze;
    final cells = cellCoordinates.map((c) => state.board.getAt(c.x, c.y)).toList();
    if (shouldReveal(cells, state.wordsToFind)) {
      final revealed = reveal(cellCoordinates, state.revealed);
      final paths = getRevealedPaths(state.board, revealed, state.wordsToFind);
      store.dispatch(UpdateMazeState(state.copyWith(
        revealed: revealed,
        paths: paths,
      )));
    }
  };
}
