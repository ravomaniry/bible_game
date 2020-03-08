import 'dart:ui';

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
  final paths = assemblePaths(moves, board.start, board.end);
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

List<List<Coordinate>> assemblePaths(
  List<MazeMove> moves,
  Coordinate start,
  Coordinate end,
) {
  moves = [...moves];
  final paths = _getAllPaths(moves, start);
  final startToEnd = _joinStartToEnd(paths, start, end);
  return startToEnd == null ? paths : [startToEnd];
}

List<Coordinate> _joinStartToEnd(
  List<List<Coordinate>> paths,
  Coordinate start,
  Coordinate end,
) {
  final allPaths = _preparePathsForStartToEnd(paths, start, end);
  var fromStart = [
    [start]
  ];
  var fromEnd = [
    [end]
  ];
  var repeat = true;

  while (repeat) {
    final pointsNum = _countPoints(allPaths);
    fromStart = _moveAllOnce(paths: fromStart, allPaths: allPaths);
    var joined = _findCompletedPath(fromStart, fromEnd);
    if (joined == null) {
      fromEnd = _moveAllOnce(paths: fromEnd, allPaths: allPaths, forward: false);
    }
    joined = _findCompletedPath(fromStart, fromEnd);
    if (joined != null) {
      return joined;
    }
    repeat = fromStart.isNotEmpty && fromEnd.isNotEmpty && pointsNum != _countPoints(allPaths);
  }
  return null;
}

List<Coordinate> _findCompletedPath(
  List<List<Coordinate>> fromStart,
  List<List<Coordinate>> fromEnd,
) {
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

List<List<Coordinate>> _moveAllOnce({
  @required List<List<Coordinate>> paths,
  @required List<List<Coordinate>> allPaths,
  bool forward = true,
}) {
  final next = List<List<Coordinate>>();
  for (final path in paths) {
    next.addAll(_moveOnce(path: path, allPaths: allPaths, forward: forward));
  }
  return next;
}

List<List<Coordinate>> _moveOnce({
  @required List<Coordinate> path,
  @required List<List<Coordinate>> allPaths,
  bool forward = true,
}) {
  final next = List<List<Coordinate>>();
  for (var i = allPaths.length - 1; i >= 0; i--) {
    if (forward) {
      if (path.last == allPaths[i].first && allPaths[i].length > 1) {
        next.add([...path, allPaths[i][1]]);
        allPaths[i].removeAt(0);
      }
    } else {
      if (path.last == allPaths[i].last && allPaths[i].length > 1) {
        final index = allPaths[i].length - 2;
        next.add([...path, allPaths[i][index]]);
        allPaths[i].removeLast();
      }
    }
    if (allPaths[i].length <= 1) {
      allPaths.removeAt(i);
    }
  }
  return next;
}

int _countPoints(List<List<Coordinate>> paths) {
  return paths.map((x) => x.length).reduce((a, b) => a + b);
}

List<List<Coordinate>> _preparePathsForStartToEnd(
  List<List<Coordinate>> paths,
  Coordinate start,
  Coordinate end,
) {
  return paths.map((path) {
    path = [...path];
    final startIndex = path.indexOf(start);
    if (startIndex > 0) {
      path = path.getRange(startIndex, path.length).toList();
    }
    final endIndex = path.indexOf(end);
    if (endIndex >= 0 && endIndex < path.length - 1) {
      path = path.getRange(0, endIndex + 1);
    }
    return path;
  }).toList();
}

List<Coordinate> _joinLeftAndRight(List<Coordinate> left, List<Coordinate> right) {
  if (left.last == right.last) {
    return [...left, ...right.getRange(0, right.length - 1).toList().reversed];
  }
  return null;
}

List<List<Coordinate>> _getAllPaths(List<MazeMove> moves, Coordinate start) {
  final all = List<List<Coordinate>>();
  var path = [start];
  var openStart = false;
  var openEnd = false;
  while (moves.isNotEmpty) {
    final continued = _continuePath(
      path: path,
      moves: moves,
      openStart: openStart,
      openEnd: openEnd,
    );
    all.add(continued ?? path);
    if (moves.isNotEmpty) {
      path = [moves.first.start, moves.first.end];
      openStart = moves.first.isStarting;
      openEnd = moves.first.isEnding;
      if (moves.length == 1) {
        all.add(path);
      }
      moves.removeAt(0);
    }
  }
  return all;
}

List<Coordinate> _continuePath({
  @required List<Coordinate> path,
  @required List<MazeMove> moves,
  bool openStart = false,
  bool openEnd = false,
}) {
  var next = path;
  var i = moves.length - 1;
  while (i >= 0) {
    final move = moves[i];
    final before = next;
    if (move.start == next.last && !next.contains(move.end)) {
      next = [...next, move.end];
      openEnd = move.isEnding;
    } else if (move.end == next.first && !next.contains(move.start)) {
      next = [move.start, ...next];
      openStart = move.isStarting;
    } else if (!next.contains(move.start) && !next.contains(move.end)) {
      if (openEnd && move.isStarting && areNeighbors(next.last, move.start)) {
        next = [...next, move.start, move.end];
        openEnd = move.isEnding;
      } else if (openStart && move.isEnding && areNeighbors(next.first, move.end)) {
        next = [move.start, move.end, ...next];
        openStart = move.isStarting;
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
