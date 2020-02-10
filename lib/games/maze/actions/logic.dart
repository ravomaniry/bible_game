import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/utils/pair.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> proposeMaze(List<Coordinate> cellCoordinates) {
  return (store) {
    final state = store.state.maze;
    final cells = cellCoordinates.map((c) => state.board.getAt(c.x, c.y)).toList();
    if (_isCorrect(cells, state.wordsToFind)) {
      final revealed = List<Coordinate>.from(state.revealed);
      revealed.addAll(cellCoordinates);
      store.dispatch(UpdateMazeState(state.copyWith(revealed: revealed)));
      // compute paths ...
    }
  };
}

bool _isCorrect(List<MazeCell> cells, List<Word> wordsToFind) {
  final List<Pair<int, int>> wordLengths = [];
  for (final cell in cells.first.cells) {
    if (cell.charIndex == 0) {
      wordLengths.add(Pair(cell.wordIndex, 0));
    }
  }

  for (final mazeCell in cells) {
    for (final cell in mazeCell.cells) {
      if (cell.wordIndex < 0) {
        return false;
      } else {
        final index = wordLengths.indexOf(Pair(cell.wordIndex, cell.charIndex));
        if (index >= 0) {
          wordLengths[index] = Pair(wordLengths[index].first, wordLengths[index].last + 1);
        }
      }
    }
  }

  for (final ref in wordLengths) {
    if (ref.last == wordsToFind[ref.first].length) {
      return true;
    }
  }
  return false;
}
