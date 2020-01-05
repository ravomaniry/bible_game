import 'dart:math';

import 'package:bible_game/games/maze/models.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';

Board createMazeBoard(BibleVerse verse) {
  final maxAttempts = 50;
  final words = getWordsInScopeForMaze(verse);
  final size = getBoardSize(words);
  for (var i = 0; i < maxAttempts; i++) {
    final board = Board.create(size, size);
    final isDone = placeWordsInBoard(words, board);
    if (isDone) {
      return board.trim();
    }
  }
  return null;
}

int getBoardSize(List<Word> words) {
  final lengths = words.map((x) => x.chars.length);
  final totalLength = lengths.reduce((a, b) => a + b);
  return totalLength * 2;
}

List<Word> getWordsInScopeForMaze(BibleVerse verse) {
  return verse.words.where((w) => !w.isSeparator).toList();
}

bool placeWordsInBoard(List<Word> words, Board board) {
  final random = Random();
  final overlapProbability = 0.85;

  for (var index = 0; index < words.length; index++) {
    final startingPoints = getPossibleStartingPoints(index, board);
    final overlaps = getOverlaps(index, words, board);
    Move move;
    if (overlaps.isNotEmpty && random.nextDouble() <= overlapProbability) {
      move = overlaps[random.nextInt(overlaps.length)];
    } else {
      final moves = getPossibleMoves(startingPoints, words.length, board);
      if (moves.isEmpty) {
        return false;
      }
      move = moves[random.nextInt(moves.length)];
    }
    if (move.origin.x < 0 || move.origin.y < 0) {
      print("Fault here! $move");
    }
    persistMove(move, words[index].length, index, board);
  }
  return true;
}

List<Move> getPossibleMoves(List<Coordinate> startingPoints, int length, Board board) {
  final List<Move> possibleMoves = [];
  for (final point in startingPoints) {
    for (final direction in Coordinate.directionsList) {
      final move = Move(point, direction);
      if (_moveIsPossible(move, length, board)) {
        possibleMoves.add(move);
      }
    }
  }
  return possibleMoves;
}

List<Coordinate> getPossibleStartingPoints(int index, Board board) {
  if (index == 0) {
    return [Coordinate(0, (board.height / 2).floor())];
  }
  final lastPoint = _getLastPoint(index, board);
  final points = Coordinate.directionsList.map((delta) => lastPoint + delta).toList();
  return points.where((p) => board.isIn(p) && board.isFreeAt(p)).toList();
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

bool _moveIsPossible(
  Move move,
  int length,
  Board board, {
  List<Coordinate> allowOverlapAt = const [],
}) {
  var currentPos = move.origin - move.direction;
  for (var remaining = length; remaining > 0; remaining--) {
    currentPos += move.direction;
    if (board.isIn(currentPos)) {
      if (!board.isFreeAt(currentPos) &&
          allowOverlapAt.where((c) => c.isSameAs(currentPos)).isEmpty) {
        return false;
      }
    } else {
      return false;
    }
  }
  return true;
}

void persistMove(Move move, int length, int index, Board board) {
  var position = move.origin;
  for (var i = 0; i < length; i++) {
    board.set(position.x, position.y, index, i);
    position += move.direction;
  }
}

List<Move> getOverlaps(int index, List<Word> words, Board board) {
  final List<Move> moves = [];
  if (index == 0 || words[index - 1].length == 1 || words[index].length == 1) {
    return moves;
  }
  final overlapIndexes = _getOverlapIndexes(words[index - 1], words[index]);
  final prevDirection = board.coordinateOf(index - 1, 1) - board.coordinateOf(index - 1, 0);
  for (final indexes in overlapIndexes) {
    final overlapPoint = board.coordinateOf(index - 1, indexes.first);
    for (final direction in Coordinate.directionsList) {
      if (!direction.isSameAs(prevDirection)) {
        final startingPoint = (direction * -indexes.last) + overlapPoint;
        final move = Move(startingPoint, direction);
        if (_moveIsPossible(move, words[index].length, board, allowOverlapAt: [overlapPoint])) {
          moves.add(move);
        }
      }
    }
  }
  return moves;
}

List<List<int>> _getOverlapIndexes(Word placed, Word toPlace) {
  final List<List<int>> overlaps = [];
  for (var iPlaced = 1; iPlaced < placed.length; iPlaced++) {
    for (var iToPlace = 0; iToPlace < toPlace.length - 1; iToPlace++) {
      if (placed.chars[iPlaced].isSameAs(toPlace.chars[iToPlace])) {
        overlaps.add([iPlaced, iToPlace]);
      }
    }
  }
  return overlaps;
}
