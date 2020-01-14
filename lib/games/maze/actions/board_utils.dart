import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/move.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';

int getBoardSize(List<Word> words) {
  final lengths = words.map((x) => x.chars.length);
  final totalLength = lengths.reduce((a, b) => a + b);
  return totalLength * 2;
}

List<Word> getWordsInScopeForMaze(BibleVerse verse) {
  return verse.words.where((w) => !w.isSeparator).toList();
}

bool isNearFirstPoint(Coordinate point, Board board) {
  final neighbors = getNeighbors(point);
  for (final neighbor in neighbors) {
    if (board.includes(neighbor)) {
      final cells = board.getAt(neighbor.x, neighbor.y);
      for (final cell in cells.cells) {
        if (cell.charIndex == 0) {
          return true;
        }
      }
    }
  }
  return false;
}

List<Coordinate> getNeighbors(Coordinate point) {
  return Coordinate.directionsList
      .map((delta) => point + delta)
      .where((c) => c.x == point.x || c.y == point.y)
      .toList();
}

bool isNearLastPoint(Coordinate point, int index, Board board, List<Word> words, {int rightOffset = 0}) {
  final neighbors = getNeighbors(point).where(board.includes).toList();
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

bool formDiagonalCross(Coordinate point, Coordinate direction, Board board) {
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

void persistMove(Move move, Board board) {
  var position = move.origin;
  for (var i = 0; i < move.length; i++) {
    board.set(position.x, position.y, move.wordIndex, i);
    position += move.direction;
  }
}

bool overlapIsAllowed(Coordinate point, Coordinate allowOverlapAt, Board board, {bool allowMultiOverlap = false}) {
  if (allowOverlapAt != null) {
    return allowOverlapAt.isSameAs(point) && (allowMultiOverlap || !board.getAt(point.x, point.y).isOverlapping);
  }
  return false;
}

List<Move> getUniqueMoves(List<Move> moves) {
  final List<Move> unique = [];
  for (final move in moves) {
    if (!_moveIsPresentIn(move, unique)) {
      unique.add(move);
    }
  }
  return unique;
}

bool _moveIsPresentIn(Move move, List<Move> moves) {
  return moves
      .where((m) =>
          m.origin.isSameAs(move.origin) && m.direction.isSameAs(move.direction) && m.wordIndex == move.wordIndex)
      .isNotEmpty;
}
