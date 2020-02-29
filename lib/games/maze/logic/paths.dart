import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/utils/pair.dart';

final _directions = [Coordinate.upRight, Coordinate.right, Coordinate.downRight, Coordinate.down];

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
  final List<Coordinate> toSkip = [];
  final List<Pair<Coordinate, Coordinate>> moves = [];
  for (var y = 0, h = revealed.length; y < h; y++) {
    for (var x = 0, w = revealed[y].length; x < w; x++) {
      _appendMove(Coordinate(x, y), moves, toSkip, board, revealed);
    }
  }
  return moves;
}

void _appendMove(
  Coordinate start,
  List<Pair<Coordinate, Coordinate>> moves,
  List<Coordinate> toSkip,
  Board board,
  List<List<bool>> revealed,
) {
  final index = toSkip.indexOf(start);
  if (index == -1) {
    var appended = false;
    for (final direction in _directions) {
      final end = _getMoveEnd(start, direction, board, revealed);
      if (end != null) {
        appended = true;
        moves.add(Pair(start, end));
        _appendToSkip(toSkip, start, end, direction, board);
      }
    }
    if (!appended && revealed[start.y][start.x]) {
      moves.add(Pair(start, start));
    }
  } else {
    toSkip.removeAt(index);
  }
}

Coordinate _getMoveEnd(
  Coordinate start,
  Coordinate direction,
  Board board,
  List<List<bool>> revealed,
) {
  if (revealed[start.y][start.x]) {
    var point = start;
    var mazeCell = board.getAt(point.x, point.y);
    var wordIndexes = [for (final cell in mazeCell.cells) cell.wordIndex];
    final returnValue = () => point == start ? null : point;

    while (true) {
      final next = point + direction;
      if (board.includes(next) && revealed[next.y][next.x]) {
        final nextCell = board.getAt(next.x, next.y);
        final wordIndex = nextCell.first.wordIndex;
        if (nextCell.cells.length == 1) {
          if (wordIndexes.contains(wordIndex)) {
            wordIndexes = [wordIndex];
            point = next;
          } else {
            return returnValue();
          }
        } else {
          if (nextCell.containsOneWordOf(wordIndexes)) {
            return next;
          }
          return returnValue();
        }
      } else {
        return returnValue();
      }
    }
  }
  return null;
}

void _appendToSkip(
  List<Coordinate> toSkip,
  Coordinate start,
  Coordinate end,
  Coordinate direction,
  Board board,
) {
  for (var point = start; point != end; point += direction) {
    final toAdd = point + direction;
    if (!toSkip.contains(toAdd) && board.getAt(toAdd.x, toAdd.y).cells.length == 1) {
      toSkip.add(toAdd);
    }
  }
}

List<List<Coordinate>> _assemblePaths(
  List<Pair<Coordinate, Coordinate>> moves,
  Coordinate start,
  Coordinate end,
) {
  final paths = List<List<Coordinate>>();

  return paths;
}
