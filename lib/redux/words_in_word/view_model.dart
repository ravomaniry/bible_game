import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/actions.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/inventory/actions.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:bible_game/redux/inventory/use_bonus_action.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:bible_game/redux/words_in_word/cells_action.dart';
import 'package:bible_game/redux/words_in_word/logics.dart';
import 'package:bible_game/redux/words_in_word/state.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class WordsInWordViewModel {
  final InventoryState inventory;
  final WordsInWordState wordsInWord;
  final ConfigState config;
  final Function(Char) selectHandler;
  final Function() submitHandler;
  final Function() cancelHandler;
  final Function(double) updateScreenWidth;
  final Function(int) slotClickHandler;
  final Function() propose;
  final Function() tempNextVerseHandler;
  final Function() shuffleSlots;
  final Function() invalidateCombo;
  final Function(Bonus) useBonus;

  WordsInWordViewModel({
    @required this.inventory,
    @required this.wordsInWord,
    @required this.config,
    @required this.selectHandler,
    @required this.submitHandler,
    @required this.cancelHandler,
    @required this.updateScreenWidth,
    @required this.slotClickHandler,
    @required this.propose,
    @required this.tempNextVerseHandler,
    @required this.shuffleSlots,
    @required this.invalidateCombo,
    @required this.useBonus,
  });

  static WordsInWordViewModel converter(Store<AppState> store) {
    return WordsInWordViewModel(
      config: store.state.config,
      inventory: store.state.inventory,
      wordsInWord: store.state.wordsInWord,
      selectHandler: (Char char) => store.dispatch(SelectWordsInWordChar(char)),
      submitHandler: () => store.dispatch(SubmitWordsInWordResponse()),
      cancelHandler: () => store.dispatch(CancelWordsInWordResponse()),
      updateScreenWidth: (double screenWidth) {
        store.dispatch(UpdateScreenWidth(screenWidth));
        store.dispatch(ComputeCells(screenWidth).thunk);
        store.dispatch(recomputeSlotsIndexes);
      },
      slotClickHandler: (int index) => store.dispatch(SlotClickHandler(index).thunk),
      propose: () => store.dispatch(proposeWordsInWord),
      tempNextVerseHandler: () => store.dispatch(tempWordsInWordNext),
      shuffleSlots: () => store.dispatch(shuffleSlotsAction),
      invalidateCombo: () => store.dispatch(InvalidateCombo()),
      useBonus: (Bonus bonus) => store.dispatch(UseBonus(bonus, true).thunk),
    );
  }
}
