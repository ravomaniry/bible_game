import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/utils/pair.dart';

bool shouldReveal(List<MazeCell> cells, List<Word> wordsToFind) {
  final List<Pair<int, int>> wordLengths = [];
  for (final cell in cells.first.cells) {
    if (cell.charIndex == 0) {
      wordLengths.add(Pair(cell.wordIndex, 0));
    }
  }
  for (final mazeCell in cells) {
    for (final cell in mazeCell.cells) {
      if (cell.wordIndex < 0) {
        return false;
      } else {
        final index = wordLengths.indexOf(Pair(cell.wordIndex, cell.charIndex));
        if (index >= 0) {
          wordLengths[index] = Pair(wordLengths[index].first, wordLengths[index].last + 1);
        }
      }
    }
  }
  for (final ref in wordLengths) {
    if (ref.last == cells.length && ref.last == wordsToFind[ref.first].length) {
      return true;
    }
  }
  return false;
}

List<List<bool>> reveal(List<Coordinate> cells, List<List<bool>> revealed) {
  final updated = revealed.map((x) => [...x]).toList();
  for (final cell in cells) {
    updated[cell.y][cell.x] = true;
  }
  return updated;
}

List<int> getUpdatedWordsToFind(
  List<int> wordsToFind,
  List<Coordinate> newlyRevealed,
  List<List<bool>> revealed,
  Board board,
  List<Word> words,
) {
  wordsToFind = List<int>.from(wordsToFind);
  final indexes = _getWordIndexesAt(newlyRevealed, board);
  for (final index in indexes) {
    if (_wordIsRevealed(index, board, revealed)) {
      wordsToFind.remove(index);
    }
  }
  return wordsToFind;
}

List<int> _getWordIndexesAt(List<Coordinate> points, Board board) {
  final List<int> wordIndexes = [];
  for (final point in points) {
    for (final cell in board.getAt(point.x, point.y).cells) {
      if (cell.wordIndex >= 0 && !wordIndexes.contains(cell)) {
        wordIndexes.add(cell.wordIndex);
      }
    }
  }
  return wordIndexes;
}

bool _wordIsRevealed(int index, Board board, List<List<bool>> revealed) {
  var point = board.coordinateOf(index, 0);
  if (point == null) {
    return false;
  }
  for (var i = 1; point != null; i++) {
    point = board.coordinateOf(index, i);
    if (point != null) {
      if (!revealed[point.y][point.x]) {
        return false;
      }
    }
  }
  return true;
}
