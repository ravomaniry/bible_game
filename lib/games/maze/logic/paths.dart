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

List<MazeMove> getRevealedMoves(
  Board board,
  List<List<bool>> revealed,
  List<Word> words,
) {
  final rawMoves = _getRawRevealedMoves(board, revealed);
  final appearances = _getPointsAppearances(rawMoves);
  return _mergeMoves(rawMoves, appearances);
}

List<List<Coordinate>> getRevealedPaths(
  Board board,
  List<List<bool>> revealed,
  List<Word> words,
) {
  final moves = getRevealedMoves(board, revealed, words);
  return getAllPaths(moves, board.start);
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

List<List<Coordinate>> getAllPaths(List<MazeMove> moves, Coordinate start) {
  moves = [...moves];
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
