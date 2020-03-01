import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/logic/paths.dart';
import 'package:bible_game/games/maze/logic/reveal.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> proposeMaze(List<Coordinate> cellCoordinates) {
  return (store) async {
    final state = store.state.maze;
    final board = state.board;
    final cells = cellCoordinates.map((c) => board.getAt(c.x, c.y)).toList();
    if (shouldReveal(cells, state.wordsToFind)) {
      final revealed = reveal(cellCoordinates, state.revealed);
      final paths = getRevealedPaths(state.board, revealed, state.wordsToFind);
      print(paths);
      store.dispatch(UpdateMazeState(state.copyWith(
        revealed: revealed,
        paths: paths,
      )));
      if (paths.length == 1 && paths[0].last == state.board.end) {
        await Future.delayed(Duration(seconds: 1));
        store.dispatch(UpdateGameResolvedState(true));
      }
    }
  };
}
