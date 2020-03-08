import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/logic/paths.dart';
import 'package:bible_game/games/maze/logic/reveal.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/models/word.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> proposeMaze(List<Coordinate> cellCoordinates) {
  return (store) async {
    final state = store.state.maze;
    final board = state.board;
    final words = state.wordsToFind;
    final cells = cellCoordinates.map((c) => board.getAt(c.x, c.y)).toList();
    if (shouldReveal(cells, state.wordsToFind)) {
      final revealed = reveal(cellCoordinates, state.revealed);
      if (_isCompleted(board, words, revealed)) {
        store.dispatch(UpdateGameResolvedState(true));
      } else {
        final paths = getRevealedPaths(state.board, revealed, state.wordsToFind);
        store.dispatch(UpdateMazeState(state.copyWith(
          revealed: revealed,
          paths: paths,
        )));
      }
    }
  };
}

bool _isCompleted(Board board, List<Word> words, List<List<bool>> revealed) {
  for (var wordIndex = 0; wordIndex < words.length; wordIndex++) {
    for (var charIndex = 0; charIndex < words[wordIndex].length; charIndex++) {
      final position = board.coordinateOf(wordIndex, charIndex);
      if (!revealed[position.y][position.x]) {
        return false;
      }
    }
  }
  return true;
}
