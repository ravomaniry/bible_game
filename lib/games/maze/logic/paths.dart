import 'package:bible_game/games/maze/create/board_utils.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/utils/pair.dart';

final _directions = [Coordinate.upRight, Coordinate.right, Coordinate.downRight, Coordinate.down];

List<List<Coordinate>> getRevealedPaths(
  Board board,
  List<List<bool>> revealed,
  List<Word> words,
) {
  final moves = getRevealedMoves(board, revealed, words);
  final paths = _assemblePaths(moves, board.start, board.end);
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
    if (!appended && revealed[start.y][start.x] && moves.where((m) => m.last == start).isEmpty) {
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
    var wordIndexes = mazeCell.cells.map((cell) => cell.wordIndex).toList();
    final returnValue = () => point == start ? null : point;

    while (true) {
      final next = point + direction;
      if (board.includes(next) && revealed[next.y][next.x]) {
        final nextCell = _removeUnusedCells(board.getAt(next.x, next.y), next, revealed, board);
        if (nextCell.cells.length == 1) {
          final wordIndex = nextCell.first.wordIndex;
          // TODO check this logic as this may cause bug
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
    if (toAdd != end && !toSkip.contains(toAdd)) {
      toSkip.add(toAdd);
    }
  }
}

MazeCell _removeUnusedCells(
  MazeCell mazeCell,
  Coordinate coordinate,
  List<List<bool>> revealed,
  Board board,
) {
  if (mazeCell.cells.length == 1) {
    return mazeCell;
  }
  final cells = List<Cell>();
  for (final cell in mazeCell.cells) {
    for (final dir in Coordinate.allDirections) {
      final next = coordinate + dir;
      if (board.includes(next) && revealed[next.y][next.x]) {
        final wordIndexes = board.getAt(next.x, next.y).cells.map((c) => c.wordIndex);
        if (wordIndexes.contains(cell.wordIndex)) {
          cells.add(cell);
          break;
        }
      }
    }
  }
  if (cells.isEmpty) {
    return mazeCell;
  }
  return MazeCell(cells);
}

List<List<Coordinate>> _assemblePaths(
  List<Pair<Coordinate, Coordinate>> moves,
  Coordinate start,
  Coordinate end,
) {
  final startToEnd = _joinStartToEnd(moves, start, end);
  if (startToEnd != null) {
    return [startToEnd];
  }
  return _getAllPaths(moves);
}

List<Coordinate> _joinStartToEnd(
  List<Pair<Coordinate, Coordinate>> moves,
  Coordinate start,
  Coordinate end,
) {
  var fromStart = [
    [start]
  ];
  var fromEnd = [
    [end]
  ];
  final movesLeft = List<Pair<Coordinate, Coordinate>>.from(moves);
  final getCompletePath = () {
    for (final left in fromStart) {
      for (final right in fromEnd) {
        if (left.last == right.last) {
          return [...left.getRange(0, left.length - 1), ...right.reversed];
        }
      }
    }
    return null;
  };

  while (fromStart.isNotEmpty && fromEnd.isNotEmpty) {
    fromStart = _continuePaths(fromStart, movesLeft);
    var completePath = getCompletePath();
    if (completePath == null) {
      fromEnd = _continuePaths(fromEnd, movesLeft);
      completePath = getCompletePath();
    }
    if (completePath != null) {
      return completePath;
    }
  }
  return null;
}

List<List<Coordinate>> _getAllPaths(List<Pair<Coordinate, Coordinate>> moves) {
  if (moves.isEmpty) {
    return [];
  }
  final all = List<List<Coordinate>>();
  final queue = [
    [moves.first.first]
  ];
  while (queue.isNotEmpty) {
    var paths = [queue[0]];
    while (paths.isNotEmpty) {
      final next = _continuePaths(paths, moves);
      if (next.length == 0) {
        all.addAll(paths);
        queue.removeAt(0);
        paths = [];
      } else if (next.length == 1) {
        paths = next;
      } else {
        final newPaths = next.getRange(1, next.length).map((x) => [x[x.length - 2], x.last]);
        queue.addAll(newPaths);
        paths = [next[0]];
      }
    }
  }
  return all;
}

List<List<Coordinate>> _continuePaths(
  List<List<Coordinate>> paths,
  List<Pair<Coordinate, Coordinate>> moves,
) {
  final newPaths = List<List<Coordinate>>();
  for (final path in paths) {
    final last = path.last;
    for (var i = moves.length - 1; i >= 0; i--) {
      final sameAsFirst = moves[i].first == last;
      final sameAsLast = moves[i].last == last;
      final isNeighborOfFirst = areNeighbors(moves[i].first, last);
      final isNeighborOfLast = areNeighbors(moves[i].last, last);
      if (sameAsFirst || sameAsLast || isNeighborOfFirst || isNeighborOfLast) {
        final nextPoint = sameAsLast || isNeighborOfFirst ? moves[i].first : moves[i].last;
        final newPath = [...path, nextPoint];
        if (!_containsPath(newPaths, newPath)) {
          newPaths.add(newPath);
        }
        if (sameAsFirst || sameAsLast) {
          moves.removeAt(i);
        }
      }
    }
  }
  return newPaths;
}

bool _containsPath(List<List<Coordinate>> paths, List<Coordinate> path) {
  for (final existing in paths) {
    if (existing.first == path.first && existing.last == path.last) {
      return true;
    }
  }
  return false;
}
