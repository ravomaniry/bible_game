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
