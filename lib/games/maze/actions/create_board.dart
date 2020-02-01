import 'dart:math';

import 'package:bible_game/games/maze/actions/board_noises.dart';
import 'package:bible_game/games/maze/actions/board_utils.dart';
import 'package:bible_game/games/maze/actions/environment.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/move.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';

Future<Board> createMazeBoard(BibleVerse verse, int id) async {
  final maxAttempts = 50;
  final words = getWordsInScopeForMaze(verse);
  final size = getBoardSize(words);
  for (var i = 0; i < maxAttempts; i++) {
    var board = Board.create(size, size, id);
    final isDone = await placeWordsInBoard(words, board);
    if (isDone) {
      board = board.trim();
      await addNoises(board, words);
      assignWaters(board);
      return board;
    }
  }
  return null;
}

Future<bool> placeWordsInBoard(List<Word> words, Board board) async {
  final random = Random();
  final overlapProbability = 0.9;

  for (var index = 0; index < words.length; index++) {
    final startingPoints = await getPossibleStartingPoints(index, board, words);
    final overlaps = getOverlaps(index, words, board);
    Move move;
    if (overlaps.isNotEmpty && random.nextDouble() <= overlapProbability) {
      move = overlaps[random.nextInt(overlaps.length)];
    } else {
      final moves = getPossibleMoves(startingPoints, index, words[index].length, board);
      if (moves.isEmpty) {
        return false;
      }
      move = moves[random.nextInt(moves.length)];
    }
    persistMove(move, board);

    if (index == 0) {
      board.start = move.origin;
    }
  }
  return true;
}

List<Move> getPossibleMoves(List<Coordinate> startingPoints, int index, int length, Board board) {
  final List<Move> possibleMoves = [];
  for (final point in startingPoints) {
    for (final direction in Coordinate.directionsList) {
      final move = Move(point, direction, index, length);
      if (_moveIsPossible(move, length, board)) {
        possibleMoves.add(move);
      }
    }
  }
  return possibleMoves;
}

Future<List<Coordinate>> getPossibleStartingPoints(int index, Board board, List<Word> words) async {
  if (index == 0) {
    return [Coordinate(0, (board.height / 2).floor())];
  }
  await Future.delayed(const Duration(milliseconds: 2));
  final lastPoint = _getLastPoint(index, board);
  final neighbors = getNeighbors(lastPoint);
  return neighbors
      .where((p) => board.includes(p) && board.isFreeAt(p))
      .where((p) => !isNearLastPoint(p, index, board, words, rightOffset: 1))
      .toList();
}

Coordinate _getLastPoint(int index, Board board) {
  var lastPoint = Coordinate(0, 0);
  var maxCharIndexSoFar = -1;
  if (index == 0) {
    return lastPoint;
  }
  board.forEach((point, x, y) {
    if (point.wordIndex == index - 1 && point.charIndex > maxCharIndexSoFar) {
      maxCharIndexSoFar = point.charIndex;
      lastPoint = Coordinate(x, y);
    }
  });
  return lastPoint;
}

bool _moveIsPossible(Move move, int length, Board board) {
  var currentPos = move.origin - move.direction;
  for (var remaining = length; remaining > 0; remaining--) {
    if (remaining != length && formDiagonalCross(currentPos, move.direction, board)) {
      return false;
    }
    currentPos += move.direction;
    if (board.includes(currentPos)) {
      if (!board.isFreeAt(currentPos) && !overlapIsAllowed(currentPos, move.overlapAt, board)) {
        return false;
      }
    } else {
      return false;
    }
  }
  return true;
}

List<Move> getOverlaps(int index, List<Word> words, Board board) {
  final List<Move> moves = [];
  if (index == 0 || words[index - 1].length == 1 || words[index].length == 1) {
    return moves;
  }
  final overlapIndexes = getOverlapIndexes(words[index - 1], words[index]);
  final prevDirection = board.coordinateOf(index - 1, 1) - board.coordinateOf(index - 1, 0);
  for (final indexes in overlapIndexes) {
    final overlapPoint = board.coordinateOf(index - 1, indexes.first);
    for (final direction in Coordinate.directionsList) {
      if (!direction.isSameAs(prevDirection)) {
        final startingPoint = (direction * -indexes.last) + overlapPoint;
        final isNearPrevLastPoint = isNearLastPoint(startingPoint, index, board, words, rightOffset: 0);
        final isNearOtherLastPoints = isNearLastPoint(startingPoint, index, board, words, rightOffset: 1);
        if (!isNearOtherLastPoints && (!isNearPrevLastPoint || startingPoint.isSameAs(overlapPoint))) {
          final move = Move(startingPoint, direction, index, words[index].length, overlapAt: overlapPoint);
          if (_moveIsPossible(move, words[index].length, board)) {
            moves.add(move);
          }
        }
      }
    }
  }
  return moves;
}
