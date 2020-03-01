import 'package:bible_game/games/maze/create/board_utils.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/utils/pair.dart';

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
  final rawMoves = _getRawRevealedMoves(board, revealed);
  final appearances = _getPointsAppearances(rawMoves);
  return _mergeMoves(rawMoves, appearances);
}

List<List<Coordinate>> _getRawRevealedMoves(Board board, List<List<bool>> revealed) {
  final moves = List<List<Coordinate>>();
  for (var y = 0, height = board.height; y < height; y++) {
    for (final cellMoves in board.moves[y]) {
      for (final move in cellMoves) {
        if (_moveIsAllRevealed(move, revealed)) {
          moves.add(move);
        }
      }
    }
  }
  return moves;
}

bool _moveIsAllRevealed(List<Coordinate> move, List<List<bool>> revealed) {
  for (final point in move) {
    if (!revealed[point.y][point.x]) {
      return false;
    }
  }
  return true;
}

Map<Coordinate, int> _getPointsAppearances(List<List<Coordinate>> rawMoves) {
  final map = Map<Coordinate, int>();
  for (final move in rawMoves) {
    for (var i = 0, max = move.length; i < max; i++) {
      if (map[move[i]] == null) {
        map[move[i]] = 1;
      } else {
        map[move[i]]++;
      }
    }
  }
  return map;
}

List<Pair<Coordinate, Coordinate>> _mergeMoves(
  List<List<Coordinate>> rawMoves,
  Map<Coordinate, int> appearances,
) {
  final moves = List<Pair<Coordinate, Coordinate>>();
  for (final points in rawMoves) {
    var start = points[0];
    for (var i = 1; i < points.length - 1; i++) {
      final point = points[i];
      if (appearances[point] > 1) {
        moves.add(Pair(start, point));
        start = point;
      }
    }
    moves.add(Pair(start, points.last));
  }
  return moves;
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
    if (moves.isNotEmpty && queue.isEmpty) {
      queue.add([moves.first.first]);
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
