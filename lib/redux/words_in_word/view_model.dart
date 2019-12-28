import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/actions.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/game/next_verse.dart';
import 'package:bible_game/redux/inventory/actions.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:bible_game/redux/inventory/use_bonus_action.dart' as bonusActions;
import 'package:bible_game/redux/themes/themes.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:bible_game/redux/words_in_word/cells_action.dart';
import 'package:bible_game/redux/words_in_word/logics.dart' as logic;
import 'package:bible_game/redux/words_in_word/state.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class WordsInWordViewModel {
  final BibleVerse verse;
  final InventoryState inventory;
  final WordsInWordState wordsInWord;
  final ConfigState config;
  final AppColorTheme theme;
  final Function(Char) selectHandler;
  final Function() submitHandler;
  final Function() cancelHandler;
  final Function(double) updateScreenWidth;
  final Function(int) slotClickHandler;
  final Function() propose;
  final Function() nextHandler;
  final Function() shuffleSlots;
  final Function() invalidateCombo;
  final Function(Bonus) useBonus;
  final Function() stopPropositionAnimationHandler;

  WordsInWordViewModel({
    @required this.verse,
    @required this.inventory,
    @required this.wordsInWord,
    @required this.config,
    @required this.selectHandler,
    @required this.submitHandler,
    @required this.cancelHandler,
    @required this.updateScreenWidth,
    @required this.slotClickHandler,
    @required this.propose,
    @required this.nextHandler,
    @required this.shuffleSlots,
    @required this.invalidateCombo,
    @required this.useBonus,
    @required this.theme,
    @required this.stopPropositionAnimationHandler,
  });

  static WordsInWordViewModel converter(Store<AppState> store) {
    return WordsInWordViewModel(
      config: store.state.config,
      verse: store.state.game.verse,
      inventory: store.state.game.inventory,
      wordsInWord: store.state.wordsInWord,
      theme: store.state.theme,
      selectHandler: (Char char) => store.dispatch(SelectWordsInWordChar(char)),
      submitHandler: () => store.dispatch(SubmitWordsInWordResponse()),
      cancelHandler: () => store.dispatch(CancelWordsInWordResponse()),
      updateScreenWidth: (double screenWidth) {
        store.dispatch(UpdateScreenWidth(screenWidth));
        store.dispatch(computeCellsAction(screenWidth));
        store.dispatch(recomputeSlotsIndexes());
      },
      slotClickHandler: (int index) => store.dispatch(logic.slotClickHandler(index)),
      propose: () => store.dispatch(logic.proposeWordsInWord()),
      nextHandler: () => store.dispatch(saveGameAndLoadNextVerse()),
      shuffleSlots: () => store.dispatch(logic.shuffleSlotsAction()),
      invalidateCombo: () => store.dispatch(InvalidateCombo()),
      useBonus: (Bonus bonus) => store.dispatch(bonusActions.useBonus(bonus, true)),
      stopPropositionAnimationHandler: () => store.dispatch(stopPropositionAnimation()),
    );
  }
}
