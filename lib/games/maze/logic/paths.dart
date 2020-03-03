import 'package:bible_game/games/maze/create/board_utils.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/cupertino.dart';

class MazeMove {
  final Coordinate start;
  final Coordinate end;
  final bool isStarting;
  final bool isEnding;

  MazeMove(this.start, this.end, this.isStarting, this.isEnding);

  @override
  int get hashCode => hashValues(start, end, isStarting, isEnding);

  @override
  bool operator ==(other) =>
      other is MazeMove &&
      other.start == start &&
      other.end == end &&
      other.isStarting == isStarting &&
      other.isEnding == isEnding;

  @override
  String toString() {
    return "$start $end ${isStarting ? 'isStarging' : ''} ${isEnding ? 'isEnding' : ''}";
  }
}

List<List<Coordinate>> getRevealedPaths(
  Board board,
  List<List<bool>> revealed,
  List<Word> words,
) {
  final moves = getRevealedMoves(board, revealed, words);
  final paths = _assemblePaths(moves, board.start, board.end);
  return paths;
}

List<MazeMove> getRevealedMoves(
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

List<MazeMove> _mergeMoves(
  List<List<Coordinate>> rawMoves,
  Map<Coordinate, int> appearances,
) {
  final moves = List<MazeMove>();
  for (final points in rawMoves) {
    var start = points[0];
    for (var i = 1; i < points.length - 1; i++) {
      final point = points[i];
      if (appearances[point] > 1) {
        moves.add(MazeMove(start, point, start == points[0], false));
        start = point;
      }
    }
    moves.add(MazeMove(start, points.last, start == points[0], true));
  }
  return moves;
}

List<List<Coordinate>> _assemblePaths(
  List<MazeMove> moves,
  Coordinate start,
  Coordinate end,
) {
  final startToEnd = _joinStartToEnd(moves, start, end);
  if (startToEnd != null) {
    return [startToEnd];
  }
  return getAllPaths(moves, start);
}

List<Coordinate> _joinStartToEnd(
  List<MazeMove> moves,
  Coordinate start,
  Coordinate end,
) {
  moves = [...moves];
  final fromStart = _continuePaths([
    [start]
  ], moves);
  final fromEnd = _continuePaths([
    [end]
  ], moves);

  for (final left in fromStart) {
    for (final right in fromEnd) {
      final joined = _joinLeftAndRight(left, right);
      if (joined != null) {
        return joined;
      }
    }
  }
  return null;
}

List<Coordinate> _joinLeftAndRight(List<Coordinate> left, List<Coordinate> right) {
  for (var l = left.length - 1; l >= 0; l--) {
    for (var r = 0; r < right.length; r++) {
      if (left[l] == right[r]) {
        return [...left.getRange(0, l), ...right.getRange(r, right.length)];
      }
    }
  }
  return null;
}

List<List<Coordinate>> getAllPaths(List<MazeMove> moves, Coordinate start) {
  final all = List<List<Coordinate>>();
  var path = [start];
  while (moves.isNotEmpty) {
    final continued = _continuePath(path, moves);
    all.add(continued ?? path);
    if (moves.isNotEmpty) {
      path = [moves.first.start, moves.first.end];
      if (moves.length == 1) {
        all.add(path);
      }
      moves.removeAt(0);
      // handle isStarting && isEnding here
    }
  }
  return all;
}

List<List<Coordinate>> _continuePaths(List<List<Coordinate>> paths, List<MazeMove> moves) {
  final newPaths = List<List<Coordinate>>();
  for (final path in paths) {
    final continued = _continuePath(path, moves);
    if (continued != null) {
      newPaths.add(continued);
    }
  }
  return newPaths;
}

List<Coordinate> _continuePath(List<Coordinate> path, List<MazeMove> moves) {
  var next = path;
  var i = moves.length - 1;
  while (i >= 0) {
    final move = moves[i];
    final before = next;
    if (move.start == next.last && !next.contains(move.end)) {
      next = [...next, move.end];
    } else if (move.end == next.first && !next.contains(move.start)) {
      next = [move.start, ...next];
    } else if (!next.contains(move.start) && !next.contains(move.end)) {
      if (move.isStarting && areNeighbors(next.last, move.start)) {
        next = [...next, move.start, move.end];
      } else if (move.isEnding && areNeighbors(next.first, move.end)) {
        next = [move.start, move.end, ...next];
      }
    }
    if (next != before) {
      moves.removeAt(i);
      i = moves.length - 1;
    } else {
      i--;
    }
  }
  return next == path ? null : next;
}
