import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/actions.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:bible_game/redux/words_in_word/cells_action.dart';
import 'package:bible_game/redux/words_in_word/logics.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class WordsInWordViewModel {
  final BibleVerse verse;
  final List<List<Cell>> cells;
  final List<Word> resolvedWords;
  final List<Word> wordsToFind;
  final List<Char> slots;
  final List<Char> proposition;
  final double screenWidth;
  final Function(Char) selectHandler;
  final Function() submitHandler;
  final Function() cancelHandler;
  final Function(double) updateScreenWidth;
  final Function(int) slotClickHandler;
  final Function() propose;
  final Function() tempNextVerseHandler;
  final Function() shuffleSlots;

  WordsInWordViewModel({
    @required this.verse,
    @required this.cells,
    @required this.resolvedWords,
    @required this.wordsToFind,
    @required this.slots,
    @required this.proposition,
    @required this.screenWidth,
    @required this.selectHandler,
    @required this.submitHandler,
    @required this.cancelHandler,
    @required this.updateScreenWidth,
    @required this.slotClickHandler,
    @required this.propose,
    @required this.tempNextVerseHandler,
    @required this.shuffleSlots,
  });

  static WordsInWordViewModel converter(Store<AppState> store) {
    return WordsInWordViewModel(
      verse: store.state.wordsInWord.verse,
      cells: store.state.wordsInWord.cells,
      wordsToFind: store.state.wordsInWord.wordsToFind,
      resolvedWords: store.state.wordsInWord.resolvedWords,
      slots: store.state.wordsInWord.slots,
      proposition: store.state.wordsInWord.proposition,
      screenWidth: store.state.config.screenWidth,
      selectHandler: (Char char) => store.dispatch(SelectWordsInWordChar(char)),
      submitHandler: () => store.dispatch(SubmitWordsInWordResponse()),
      cancelHandler: () => store.dispatch(CancelWordsInWordResponse()),
      updateScreenWidth: (double screenWidth) {
        store.dispatch(UpdateScreenWidth(screenWidth));
        store.dispatch(ComputeCells(screenWidth).thunk);
      },
      slotClickHandler: (int index) => store.dispatch(SlotClickHandler(index).thunk),
      propose: () => store.dispatch(proposeWordsInWord),
      tempNextVerseHandler: () => store.dispatch(tempWordsInWordNext),
      shuffleSlots: () => store.dispatch(shuffleSlotsAction),
    );
  }
}
