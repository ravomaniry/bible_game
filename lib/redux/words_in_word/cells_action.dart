import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';

class UpdateWordsInWordCells {
  List<List<Cell>> payload;

  UpdateWordsInWordCells(this.payload);
}

ThunkAction<AppState> recomputeCells = (Store<AppState> store) {
  final cells = computeCells(store.state.wordsInWord.verse.words, store.state.config.screenWidth);
  store.dispatch(UpdateWordsInWordCells(cells));
};

class ComputeCells {
  final double screenWidth;
  ThunkAction<AppState> thunk;

  ComputeCells(this.screenWidth) {
    this.thunk = (Store<AppState> store) {
      final cells = computeCells(store.state.wordsInWord.verse.words, screenWidth);
      store.dispatch(UpdateWordsInWordCells(cells));
    };
  }
}

List<List<Cell>> computeCells(List<Word> words, double screenWidth) {
  final List<List<Cell>> cells = [];
  final cellWidth = 20;
  final idealMaxWidth = screenWidth * 0.85;
  double currentX = 0;
  int currentIndex = 0;

  if (screenWidth == 0) {
    return cells;
  } else {
    cells.add([]);
  }

  for (int wordIndex = 0; wordIndex < words.length; wordIndex++) {
    final word = words[wordIndex];
    final width = cellWidth * word.chars.length.toDouble();
    if (currentX + width <= idealMaxWidth) {
      currentX += width;
    } else {
      currentIndex++;
      currentX = width;
      cells.add([]);
    }
    for (int charIndex = 0; charIndex < word.chars.length; charIndex++) {
      cells[currentIndex].add(Cell(wordIndex, charIndex));
    }
  }
  return cells;
}
