import 'dart:math';

import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/games/words_in_word/actions/action_creators.dart';
import 'package:bible_game/games/words_in_word/actions/bonus.dart';
import 'package:bible_game/games/words_in_word/actions/cells_action.dart';
import 'package:bible_game/games/words_in_word/actions/logics.dart';
import 'package:bible_game/models/word.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

/// Anagram is a variant of Words in word with only one word :)

ThunkAction<AppState> initializeAnagram() {
  return (store) {
    store.dispatch(_resolveOneCharWords());
    store.dispatch(addBonusesToVerse(probability: 0.5, power: 0.8));
    store.dispatch(initializeState());
    store.dispatch(_generateSlots());
  };
}

ThunkAction<AppState> proposeAnagram() {
  return (Store<AppState> store) {
    final state = store.state.wordsInWord;
    if (state.slots.length == state.proposition.length) {
      final hasFoundMatch = propose(store);
      if (hasFoundMatch) {
        store.dispatch(_generateSlots());
      }
    } else {
      store.dispatch(_dismissProposition());
    }
  };
}

ThunkAction<AppState> _resolveOneCharWords() {
  return (store) {
    final verse = store.state.game.verse;
    final nextWords = List<Word>.from(verse.words);
    for (var i = 0; i < nextWords.length; i++) {
      if (!nextWords[i].isSeparator && nextWords[i].chars.length == 1) {
        nextWords[i] = nextWords[i].copyWith(resolved: true);
      }
    }
    store.dispatch(UpdateGameVerse(verse.copyWith(words: nextWords)));
  };
}

ThunkAction<AppState> _generateSlots() {
  return (store) {
    final random = Random();
    final state = store.state.wordsInWord;
    final wordsToFind = state.wordsToFind;
    if (wordsToFind.isNotEmpty) {
      final word = wordsToFind[random.nextInt(wordsToFind.length)];
      final slots = (List<Char>.from(word.chars)..shuffle()).map((c) => c.toSlotChar()).toList();
      store.dispatch(UpdateWordsInWordState(state.copyWith(
        slots: slots,
        slotsBackup: slots,
      )));
      store.dispatch(recomputeSlotsIndexes());
    }
  };
}

ThunkAction<AppState> _dismissProposition() {
  return (store) {
    final state = store.state.wordsInWord;
    store.dispatch(UpdateWordsInWordState(state.copyWith(
      slots: state.slotsBackup,
      proposition: [],
    )));
  };
}
