import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/config/actions.dart';
import 'package:bible_game/app/config/state.dart';
import 'package:bible_game/app/game/actions/next_verse.dart';
import 'package:bible_game/app/inventory/actions/actions.dart';
import 'package:bible_game/app/inventory/reducer/state.dart';
import 'package:bible_game/app/inventory/actions/bonus.dart' as bonusActions;
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/words_in_word/actions/action_creators.dart';
import 'package:bible_game/games/anagram/actions/logic.dart';
import 'package:bible_game/games/words_in_word/actions/cells_action.dart';
import 'package:bible_game/games/words_in_word/actions/logics.dart' as logic;
import 'package:bible_game/games/words_in_word/reducer/state.dart';
import 'package:bible_game/games/words_in_word/view_model.dart';
import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';

class AnagramViewModel implements WordsInWordViewModel {
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

  AnagramViewModel({
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

  static AnagramViewModel converter(Store<AppState> store) {
    return AnagramViewModel(
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
      propose: () => store.dispatch(proposeAnagram()),
      nextHandler: () => store.dispatch(saveGameAndLoadNextVerse()),
      shuffleSlots: () => store.dispatch(logic.shuffleSlotsAction()),
      invalidateCombo: () => store.dispatch(InvalidateCombo()),
      useBonus: (Bonus bonus) => store.dispatch(bonusActions.useBonus(bonus, true)),
      stopPropositionAnimationHandler: () => store.dispatch(stopPropositionAnimation()),
    );
  }
}
