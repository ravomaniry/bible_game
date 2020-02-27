import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/models/board.dart';
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
      final revealed = _reveal(cellCoordinates, state.revealed);
      final paths = _getPaths(state.board, revealed, state.wordsToFind);
      store.dispatch(UpdateMazeState(state.copyWith(
        revealed: revealed,
        paths: paths,
      )));
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
    if (ref.last == cells.length && ref.last == wordsToFind[ref.first].length) {
      return true;
    }
  }
  return false;
}

List<List<bool>> _reveal(List<Coordinate> cells, List<List<bool>> revealed) {
  final updated = revealed.map((x) => [...x]).toList();
  for (final cell in cells) {
    updated[cell.y][cell.x] = true;
  }
  return updated;
}

List<List<Coordinate>> _getPaths(
  Board board,
  List<List<bool>> revealed,
  List<Word> words,
) {
  final List<List<Coordinate>> paths = [];
  final moves = getRevealedMoves(board, revealed, words);
  return paths;
}

List<Pair<Coordinate, Coordinate>> getRevealedMoves(
  Board board,
  List<List<bool>> revealed,
  List<Word> words,
) {
  final List<Coordinate> toSkip = [];
  final List<Pair<Coordinate, Coordinate>> moves = [];

  for (var y = 0, h = revealed.length; y < h; y++) {
    for (var x = 0, w = revealed[y].length; x < w; x++) {
      _appendMove(Coordinate(x, y), moves, toSkip, board, revealed);
    }
  }
  return moves;
}

final _directions = [Coordinate.upRight, Coordinate.right, Coordinate.downRight, Coordinate.down];

void _appendMove(
  Coordinate start,
  List<Pair<Coordinate, Coordinate>> moves,
  List<Coordinate> toSkip,
  Board board,
  List<List<bool>> revealed,
) {
  final index = toSkip.indexOf(start);
  if (index == -1) {
    var appended = false;
    for (final direction in _directions) {
      final end = _getMoveEnd(start, direction, board, revealed);
      if (end != null) {
        appended = true;
        moves.add(Pair(start, end));
        _appendToSkip(toSkip, start, end, direction, board);
      }
    }
    if (!appended && revealed[start.y][start.x]) {
      moves.add(Pair(start, start));
    }
  } else {
    toSkip.removeAt(index);
  }
}

Coordinate _getMoveEnd(
  Coordinate start,
  Coordinate direction,
  Board board,
  List<List<bool>> revealed,
) {
  if (revealed[start.y][start.x]) {
    var point = start;
    var mazeCell = board.getAt(point.x, point.y);
    var wordIndexes = [for (final cell in mazeCell.cells) cell.wordIndex];
    final returnValue = () => point == start ? null : point;

    while (true) {
      final next = point + direction;
      if (board.includes(next) && revealed[next.y][next.x]) {
        final nextCell = board.getAt(next.x, next.y);
        final wordIndex = nextCell.first.wordIndex;
        if (nextCell.cells.length == 1) {
          if (wordIndexes.contains(wordIndex)) {
            wordIndexes = [wordIndex];
            point = next;
          } else {
            return returnValue();
          }
        } else {
          if (nextCell.containsOneWordOf(wordIndexes)) {
            return next;
          }
          return returnValue();
        }
      } else {
        return returnValue();
      }
    }
  }
  return null;
}

void _appendToSkip(
  List<Coordinate> toSkip,
  Coordinate start,
  Coordinate end,
  Coordinate direction,
  Board board,
) {
  for (var point = start; point != end; point += direction) {
    final toAdd = point + direction;
    if (!toSkip.contains(toAdd) && board.getAt(toAdd.x, toAdd.y).cells.length == 1) {
      toSkip.add(toAdd);
    }
  }
}
