import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
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
      final cells = board.getAt(neighbor.x, neighbor.y).cells;
      for (var i = 0, max = cells.length; i < max; i++) {
        if (cells[i].charIndex == 0) {
          return true;
        }
      }
    }
  }
  return false;
}

List<Coordinate> getNeighbors(Coordinate point) {
  return [
    point + Coordinate.up,
    point + Coordinate.right,
    point + Coordinate.down,
    point + Coordinate.left,
  ];
}

bool isNearLastPoint(Coordinate point, int index, Board board, List<Word> words,
    {int rightOffset = 0}) {
  final neighbors = getNeighbors(point);
  for (final neighbor in neighbors) {
    if (board.includes(neighbor)) {
      for (final cell in board.getAt(neighbor.x, neighbor.y).cells) {
        if (cell.wordIndex >= 0 && cell.wordIndex < index - rightOffset) {
          if (cell.charIndex == words[cell.wordIndex].length - 1) {
            return true;
          }
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
  board.startMove(position);
  for (var i = 0; i < move.length; i++) {
    board.set(position.x, position.y, move.wordIndex, i);
    position += move.direction;
  }
}

bool overlapIsAllowed(Coordinate point, Coordinate allowOverlapAt, Board board,
    {bool allowMultiOverlap = false}) {
  if (allowOverlapAt != null) {
    return allowOverlapAt.isSameAs(point) &&
        (allowMultiOverlap || !board.getAt(point.x, point.y).isOverlapping);
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
  for (var i = moves.length - 1; i >= 0; i--) {
    final existing = moves[i];
    if (existing.wordIndex == move.wordIndex &&
        existing.origin == move.origin &&
        existing.direction == move.direction) {
      return true;
    }
  }
  return false;
}

bool isNewCell(MazeCell cell, List<MazeCell> existing) {
  final first = cell.cells[0];
  final last = cell.cells.last;
  for (var i = 0, max = existing.length; i < max; i++) {
    final existingItem = existing[i];
    final existingFirst = existingItem.cells[0];
    final existingLast = existingItem.cells.last;
    if ((existingFirst.isSameAs(first.wordIndex, first.charIndex) &&
            existingLast.isSameAs(last.wordIndex, last.charIndex)) ||
        (existingFirst.isSameAs(last.wordIndex, last.charIndex) &&
            existingLast.isSameAs(first.wordIndex, first.charIndex))) {
      return false;
    }
  }
  return true;
}

List<List<bool>> initialRevealedState(Board board) {
  return [
    for (var y = 0; y < board.height; y++) [for (var x = 0; x < board.width; x++) false]
  ];
}

bool areNeighbors(Coordinate a, Coordinate b) {
  return getNeighbors(a).contains(b);
}
