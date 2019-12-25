import 'package:bible_game/components/words_in_word/controls.dart';
import 'package:bible_game/components/words_in_word/results.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/thunk_container.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class UpdateWordsInWordCells {
  List<List<Cell>> payload;

  UpdateWordsInWordCells(this.payload);
}

ThunkAction<AppState> recomputeCells = (Store<AppState> store) {
  final cells = computeCells(store.state.game.verse.words, store.state.config.screenWidth);
  store.dispatch(UpdateWordsInWordCells(cells));
};

class ComputeCells extends ThunkContainer {
  final double screenWidth;

  ComputeCells(this.screenWidth) {
    this.thunk = (Store<AppState> store) {
      final cells = computeCells(store.state.game.verse.words, screenWidth);
      store.dispatch(UpdateWordsInWordCells(cells));
    };
  }
}

List<List<Cell>> computeCells(List<Word> words, double screenWidth) {
  final List<List<Cell>> cells = [];
  final cellWidth = WordsInWordResult.cellWidth;
  final idealMaxWidth = screenWidth - 10;
  double currentX = 0;
  int currentIndex = 0;
  bool isNewLine = false;

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
      isNewLine = false;
    } else {
      isNewLine = true;
      currentIndex++;
      currentX = width;
      cells.add([]);
    }
    if (!isNewLine || word.value != " ") {
      for (int charIndex = 0; charIndex < word.chars.length; charIndex++) {
        cells[currentIndex].add(Cell(wordIndex, charIndex));
      }
    }
  }
  // **NOTE** A that should contain only one space is empty
  return cells.where((row) => row.length > 0).toList();
}

ThunkAction<AppState> recomputeSlotsIndexes = (Store<AppState> store) {
  final state = store.state.wordsInWord;
  final screenWidth = store.state.config.screenWidth;
  final List<List<int>> indexes = [[]];
  final outerSlotWidth = slotWidth + slotMargin;
  int rowIndex = 0;
  double currentX = 0;

  if (screenWidth > 0) {
    for (int i = 0; i < state.slots.length; i++) {
      if (currentX + outerSlotWidth > screenWidth * 0.9) {
        rowIndex++;
        indexes.add([]);
        currentX = 0;
      }
      indexes[rowIndex].add(i);
      currentX += outerSlotWidth;
    }
    store.dispatch(UpdateWordsInWordState(state.copyWith(slotsDisplayIndexes: indexes)));
  }
};
