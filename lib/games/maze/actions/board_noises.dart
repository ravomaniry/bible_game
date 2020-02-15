import 'dart:math';

import 'package:bible_game/games/maze/actions/board_utils.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/games/maze/models/move.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';

void addNoises(Board board, List<Word> words) {
  final noiseRatio = 2;
  final minNoisesNum = 10;
  final random = Random();
  final overlapMoves = getOverlapNoiseMoves(board, words);
  final remainingMoves = List<Move>.from(overlapMoves);
  final stopAt = overlapMoves.length - max(minNoisesNum, words.length * noiseRatio);
  while (remainingMoves.length > stopAt) {
    final move = remainingMoves[random.nextInt(remainingMoves.length)];
    remainingMoves.remove(move);
    if (_noiseMoveIsPossible(move, board, words)) {
      persistMove(move, board);
    }
  }
}

List<Move> getOverlapNoiseMoves(Board board, List<Word> words) {
  final refs = getNoiseOverlapRefs(words);
  final moves = getAllPossibleNoiseOverlapMoves(board, words, refs);
  return getUniqueMoves(moves);
}

List<MazeCell> getNoiseOverlapRefs(List<Word> words) {
  final List<MazeCell> allOverlaps = [];
  for (var w0 = 0; w0 < words.length - 1; w0++) {
    for (var w1 = w0; w1 < words.length - 1; w1++) {
      final overlaps = getOverlapIndexes(words[w0], words[w1], leftOffset: 0, rightOffset: 0);
      for (final overlap in overlaps) {
        final ref = MazeCell.create(w0, overlap.first).concat(w1, overlap.last);
        final isNew = allOverlaps.where((o) {
          return (o.first.isSameAs(ref.first.wordIndex, ref.first.charIndex) &&
                  o.last.isSameAs(ref.last.wordIndex, ref.last.charIndex)) ||
              (o.first.isSameAs(ref.last.wordIndex, ref.last.charIndex) &&
                  o.last.isSameAs(ref.first.wordIndex, ref.first.charIndex));
        }).isEmpty;
        if (isNew) {
          allOverlaps.add(ref);
        }
      }
    }
  }
  return allOverlaps;
}

List<Move> getAllPossibleNoiseOverlapMoves(Board board, List<Word> words, List<MazeCell> refs) {
  final List<Move> moves = [];
  for (final ref in refs) {
    final delta = _getPossibleNoiseOverlapMoves(words, board, ref);
    moves.addAll(delta);
  }
  return moves;
}

List<List<int>> getOverlapIndexes(Word placed, Word toPlace,
    {int leftOffset = 1, int rightOffset = 1}) {
  final List<List<int>> overlaps = [];
  for (var iPlaced = leftOffset; iPlaced < placed.length; iPlaced++) {
    for (var iToPlace = 0; iToPlace < toPlace.length - rightOffset; iToPlace++) {
      if (placed.chars[iPlaced].isSameAs(toPlace.chars[iToPlace])) {
        overlaps.add([iPlaced, iToPlace]);
      }
    }
  }
  return overlaps;
}

List<Move> _getPossibleNoiseOverlapMoves(List<Word> words, Board board, MazeCell ref) {
  final List<Move> moves = [];
  List<Coordinate> overlappingPoints;
  List<Cell> guestCells;
  if (ref.first.isSameAs(ref.last.wordIndex, ref.last.charIndex)) {
    overlappingPoints = [board.coordinateOf(ref.first.wordIndex, ref.first.charIndex)];
    guestCells = [ref.last];
  } else {
    overlappingPoints = [
      board.coordinateOf(ref.first.wordIndex, ref.first.charIndex),
      board.coordinateOf(ref.last.wordIndex, ref.last.charIndex),
    ];
    guestCells = [ref.last, ref.first];
  }

  for (var i = 0; i < overlappingPoints.length; i++) {
    final overlapAt = overlappingPoints[i];
    for (final direction in Coordinate.directionsList) {
      final startPoint = (direction * -guestCells[i].charIndex) + overlapAt;
      final length = words[guestCells[i].wordIndex].length;
      final move =
          Move(startPoint, direction, guestCells[i].wordIndex, length, overlapAt: overlapAt);
      if (_noiseMoveIsPossible(move, board, words)) {
        moves.add(move);
      }
    }
  }
  return moves;
}

bool _noiseMoveIsPossible(Move move, Board board, List<Word> words) {
  final end = move.end;
  var currentPos = move.origin;

  if (!board.includes(move.origin) || !board.includes(end)) {
    return false;
  } else if ((isNearFirstPoint(move.origin, board) ||
          isNearLastPoint(move.origin, words.length, board, words)) &&
      !move.origin.isSameAs(move.overlapAt)) {
    return false;
  } else if ((isNearFirstPoint(end, board) || isNearLastPoint(end, words.length, board, words)) &&
      !end.isSameAs(move.overlapAt)) {
    return false;
  }

  for (var i = 0; i < words[move.wordIndex].length; i++) {
    if (board.isFreeAt(currentPos) ||
        overlapIsAllowed(currentPos, move.overlapAt, board, allowMultiOverlap: true)) {
      if (formDiagonalCross(currentPos, move.direction, board)) {
        return false;
      }
    } else {
      return false;
    }
    currentPos += move.direction;
  }
  return true;
}
