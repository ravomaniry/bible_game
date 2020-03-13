import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/utils/pair.dart';
import 'package:redux_thunk/redux_thunk.dart';

Word getRevealedWord(List<MazeCell> cells, List<Word> words) {
  final List<Pair<int, int>> wordLengths = [];
  for (final cell in cells.first.cells) {
    if (cell.charIndex == 0) {
      wordLengths.add(Pair(cell.wordIndex, 0));
    }
  }
  for (final mazeCell in cells) {
    for (final cell in mazeCell.cells) {
      if (cell.wordIndex < 0) {
        return null;
      } else {
        final index = wordLengths.indexOf(Pair(cell.wordIndex, cell.charIndex));
        if (index >= 0) {
          wordLengths[index] = Pair(wordLengths[index].first, wordLengths[index].last + 1);
        }
      }
    }
  }
  for (final ref in wordLengths) {
    if (ref.last == cells.length && ref.last == words[ref.first].length) {
      return words[ref.first];
    }
  }
  return null;
}

List<List<bool>> reveal(List<Coordinate> cells, List<List<bool>> revealed) {
  final updated = revealed.map((x) => [...x]).toList();
  for (final cell in cells) {
    updated[cell.y][cell.x] = true;
  }
  return updated;
}

ThunkAction<AppState> updateNewlyRevealed(List<List<bool>> old) {
  return (store) {
    final current = store.state.maze.revealed;
    final newlyRevealed = List<Coordinate>.from(store.state.maze.newlyRevealed);
    for (var y = 0; y < old.length; y++) {
      for (var x = 0; x < old[0].length; x++) {
        if (current[y][x] && !old[y][x]) {
          final point = Coordinate(x, y);
          if (!newlyRevealed.contains(point)) {
            newlyRevealed.add(point);
          }
        }
      }
    }
    store.dispatch(UpdateMazeState(store.state.maze.copyWith(newlyRevealed: newlyRevealed)));
  };
}
