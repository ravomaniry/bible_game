import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/words_in_word/actions/action_creators.dart';
import 'package:bible_game/games/words_in_word/components/controls.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

final double cellWidth = 24;
final double cellHeight = 28;
final double cellMargin = 4;

class UpdateWordsInWordCells {
  List<List<Cell>> payload;

  UpdateWordsInWordCells(this.payload);
}

ThunkAction<AppState> recomputeCells() {
  return (store) {
    final cells = computeCells(store.state.game.verse.words, store.state.config.screenWidth);
    store.dispatch(UpdateWordsInWordCells(cells));
  };
}

ThunkAction<AppState> computeCellsAction(double screenWidth) {
  return (store) {
    final cells = computeCells(store.state.game.verse.words, screenWidth);
    store.dispatch(UpdateWordsInWordCells(cells));
  };
}

List<List<Cell>> computeCells(List<Word> words, double screenWidth) {
  final List<List<Cell>> cells = [];
  final maxWidth = screenWidth - 4;
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
    final width = cellWidth * word.chars.length;
    if (currentX + width <= maxWidth) {
      currentX += width;
      isNewLine = false;
    } else {
      isNewLine = true;
      currentIndex++;
      currentX = width;
      cells.add([]);
    }
    if (!isNewLine || word.value != " ") {
      var tmpWidth = 0.0;
      var overflowed = false;
      for (int charIndex = 0; charIndex < word.chars.length; charIndex++) {
        tmpWidth += cellWidth;
        if (tmpWidth > maxWidth) {
          tmpWidth = 0;
          currentIndex++;
          overflowed = true;
          cells.add([]);
        }
        cells[currentIndex].add(Cell(wordIndex, charIndex));
      }
      if (overflowed) {
        currentX = maxWidth;
      }
    }
  }
  // **NOTE** A that should contain only one space is empty
  return cells.where((row) => row.length > 0).toList();
}

ThunkAction<AppState> recomputeSlotsIndexes() {
  return (Store<AppState> store) {
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
}
