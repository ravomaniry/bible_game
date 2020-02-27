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
      final revealed = _reveal(cellCoordinates, state.revealed);
      final paths = _getPaths(revealed);
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

List<List<Coordinate>> _getPaths(List<List<bool>> revealed) {
  final List<List<Coordinate>> paths = [];
  final moves = getRevealedMoves(revealed);
  return paths;
}

List<Pair<Coordinate, Coordinate>> getRevealedMoves(List<List<bool>> revealed) {
  final List<Coordinate> toSkip = [];
  final List<Pair<Coordinate, Coordinate>> moves = [];

  for (var y = 0, h = revealed.length; y < h; y++) {
    for (var x = 0, w = revealed[y].length; x < w; x++) {
      _appendMove(Coordinate(x, y), revealed, moves, toSkip);
    }
  }
  return moves;
}

final _directions = [Coordinate.upRight, Coordinate.right, Coordinate.downRight, Coordinate.down];

void _appendMove(
  Coordinate start,
  List<List<bool>> revealed,
  List<Pair<Coordinate, Coordinate>> moves,
  List<Coordinate> toSkip,
) {
  final index = toSkip.indexOf(start);
  if (index == -1) {
    var appended = false;
    for (final direction in _directions) {
      final end = _getMoveEnd(start, direction, revealed);
      if (end != null) {
        appended = true;
        moves.add(Pair(start, end));
        _appendToSkip(start, end, direction, toSkip);
      }
    }
    if (!appended && revealed[start.y][start.x]) {
      moves.add(Pair(start, start));
    }
  } else {
    toSkip.removeAt(index);
  }
}

Coordinate _getMoveEnd(Coordinate start, Coordinate direction, List<List<bool>> revealed) {
  if (revealed[start.y][start.x]) {
    var point = start;
    while (true) {
      final next = point + direction;
      if (_isInsideBoard(next, revealed) && revealed[next.y][next.x]) {
        point = next;
      } else {
        return point == start ? null : point;
      }
    }
  }
  return null;
}

bool _isInsideBoard(Coordinate point, List<List<bool>> revealed) {
  return point.y >= 0 && point.y < revealed.length && point.x >= 0 && point.x < revealed[0].length;
}

void _appendToSkip(
  Coordinate start,
  Coordinate end,
  Coordinate direction,
  List<Coordinate> toSkip,
) {
  for (var point = start; point != end; point += direction) {
    final toAdd = point + direction;
    if (!toSkip.contains(toAdd)) {
      toSkip.add(toAdd);
    }
  }
}
