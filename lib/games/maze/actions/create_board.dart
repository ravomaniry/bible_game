import 'dart:math';

import 'package:bible_game/games/maze/models.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';

Future<Board> createMazeBoard(BibleVerse verse) async {
  final maxAttempts = 50;
  final words = getWordsInScopeForMaze(verse);
  final size = getBoardSize(words);
  for (var i = 0; i < maxAttempts; i++) {
    final board = Board.create(size, size);
    final isDone = await placeWordsInBoard(words, board);
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
      final moves = getPossibleMoves(startingPoints, words.length, board);
      if (moves.isEmpty) {
        return false;
      }
      move = moves[random.nextInt(moves.length)];
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

Future<List<Coordinate>> getPossibleStartingPoints(int index, Board board, List<Word> words) async {
  if (index == 0) {
    return [Coordinate(0, (board.height / 2).floor())];
  }
  await Future.delayed(const Duration(milliseconds: 2));
  final lastPoint = _getLastPoint(index, board);
  final neighbors = _getNeighbors(lastPoint);
  return neighbors
      .where((p) => board.includes(p) && board.isFreeAt(p))
      .where((p) => !_isNearLastPoint(p, index, board, words, rightOffset: 1))
      .toList();
}

List<Coordinate> _getNeighbors(Coordinate point) {
  return Coordinate.directionsList
      .map((delta) => point + delta)
      .where((c) => c.x == point.x || c.y == point.y)
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

bool _moveIsPossible(Move move, int length, Board board, {Coordinate allowOverlapAt}) {
  var currentPos = move.origin - move.direction;

  for (var remaining = length; remaining > 0; remaining--) {
    if (remaining != length && _formDiagonalCross(currentPos, move.direction, board)) {
      return false;
    }

    currentPos += move.direction;
    if (board.includes(currentPos)) {
      if (!board.isFreeAt(currentPos) && !_overlapIsAllowed(currentPos, allowOverlapAt, board)) {
        return false;
      }
    } else {
      return false;
    }
  }
  return true;
}

bool _overlapIsAllowed(Coordinate point, Coordinate allowOverlapAt, Board board) {
  if (allowOverlapAt != null) {
    return allowOverlapAt.isSameAs(point) && !board.getAt(point.x, point.y).isOverlapping;
  }
  return false;
}

bool _formDiagonalCross(Coordinate point, Coordinate direction, Board board) {
  if (direction.x != 0 && direction.y != 0) {
    final horizontalNeighbor = point + Coordinate(direction.x, 0);
    final verticalNeighbor = point + Coordinate(0, direction.y);
    if (board.includes(horizontalNeighbor) &&
        board.includes(verticalNeighbor) &&
        !board.isFreeAt(horizontalNeighbor) &&
        !board.isFreeAt(verticalNeighbor)) {
      final vCells = board.getAt(horizontalNeighbor.x, horizontalNeighbor.y);
      final hCells = board.getAt(verticalNeighbor.x, verticalNeighbor.y);
      for (final hCell in vCells.cells) {
        for (final vCell in hCells.cells) {
          if (hCell.wordIndex == vCell.wordIndex) {
            return true;
          }
        }
      }
    }
  }
  return false;
}

bool _isNearLastPoint(Coordinate point, int index, Board board, List<Word> words, {int rightOffset = 0}) {
  final neighbors = _getNeighbors(point).where(board.includes).toList();
  for (final neighbor in neighbors) {
    for (final cell in board.getAt(neighbor.x, neighbor.y).cells) {
      if (cell.wordIndex >= 0 && cell.wordIndex < index - rightOffset) {
        if (cell.charIndex == words[cell.wordIndex].length - 1) {
          return true;
        }
      }
    }
  }
  return false;
}

bool _isNearFirstPoint(Coordinate point, Board board) {
  final neighbors = _getNeighbors(point);
  for (final neighbor in neighbors) {
    final cells = board.getAt(neighbor.x, neighbor.y);
    for (final cell in cells.cells) {
      if (cell.charIndex == 0) {
        return true;
      }
    }
  }
  return false;
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
        final isNearPrevLastPoint = _isNearLastPoint(startingPoint, index, board, words, rightOffset: 0);
        final isNearOtherLastPoints = _isNearLastPoint(startingPoint, index, board, words, rightOffset: 1);
        if (!isNearOtherLastPoints && (!isNearPrevLastPoint || startingPoint.isSameAs(overlapPoint))) {
          final move = Move(startingPoint, direction);
          if (_moveIsPossible(move, words[index].length, board, allowOverlapAt: overlapPoint)) {
            moves.add(move);
          }
        }
      }
    }
  }
  return moves;
}

List<List<int>> _getOverlapIndexes(Word placed, Word toPlace, {int leftOffset = 1, int rightOffset = 1}) {
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

Future<List<Move>> getOverlapNoiseMoves(Board board, List<Word> words) async {
  final refs = getAllOverlapRefs(words);
  final moves = await getAllPossibleNoiseOverlapMoves(board, words, refs);
  return moves;
}

List<MazeCell> getAllOverlapRefs(List<Word> words) {
  final List<MazeCell> allOverlaps = [];
  for (var w0 = 0; w0 < words.length; w0++) {
    for (var w1 = w0; w1 < words.length; w1++) {
      final overlaps = _getOverlapIndexes(words[w0], words[w1], leftOffset: 0, rightOffset: 0);
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

Future<List<Move>> getAllPossibleNoiseOverlapMoves(Board board, List<Word> words, List<MazeCell> refs) async {
  final List<Move> moves = [];
  for (final ref in refs) {
    moves.addAll(_getPossibleNoiseOverlapMoves(words, board, ref));
  }
  await Future.delayed(const Duration(milliseconds: 1));
  return moves;
}

List<Move> _getPossibleNoiseOverlapMoves(List<Word> words, Board board, MazeCell ref) {
  final List<Move> moves = [];
  final List<Coordinate> overlappingPoints = [
    board.coordinateOf(ref.first.wordIndex, ref.first.charIndex),
    board.coordinateOf(ref.last.wordIndex, ref.last.charIndex),
  ];
  for (final overlapAt in overlappingPoints) {
    for (final direction in Coordinate.directionsList) {
      final startPoint = (direction * -ref.last.charIndex) + overlapAt;
      final move = Move(startPoint, direction);
      if (_noiseMoveIsPossible(move, board, ref.last.wordIndex, words, overlapAt)) {
        moves.add(move);
      }
    }
  }
  return moves;
}

bool _noiseMoveIsPossible(Move move, Board board, int index, List<Word> words, Coordinate overlapAt) {
  final lastPoint = move.origin + (move.direction * index);
  var hasFormedDiagonalCross = false;
  var currentPos = move.origin;

  if (!board.includes(move.origin) || !board.isFreeAt(move.origin)) {
    return false;
  } else if (!board.includes(lastPoint) || !board.isFreeAt(lastPoint)) {
    return false;
  } else if (_isNearLastPoint(move.origin, words.length - 1, board, words)) {
    return false;
  } else if (_isNearFirstPoint(lastPoint, board)) {
    return false;
  }

  for (var i = 0; i < words[index].length; i++) {
    if (board.isFreeAt(currentPos) || _overlapIsAllowed(currentPos, overlapAt, board)) {
      final formDiagonal = _formDiagonalCross(currentPos, move.direction, board);
      if (formDiagonal && hasFormedDiagonalCross) {
        return false;
      } else if (formDiagonal) {
        hasFormedDiagonalCross = true;
      }
    } else {
      return false;
    }
    currentPos += move.direction;
  }
  return true;
}
