import 'dart:math';

import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/app/inventory/actions/actions.dart';
import 'package:bible_game/app/inventory/actions/use_bonus_action.dart';
import 'package:bible_game/games/words_in_word/actions/action_creators.dart';
import 'package:bible_game/games/words_in_word/actions/cells_action.dart';
import 'package:bible_game/games/words_in_word/reducer/state.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/sfx/actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class ProposeResult {
  final BibleVerse verse;
  final bool hasFoundMatch;
  final List<Word> wordsToFind;
  final Word revealed;
  final List<Char> slots;
  final List<Word> resolvedWords;

  ProposeResult({
    @required this.verse,
    @required this.hasFoundMatch,
    @required this.wordsToFind,
    @required this.revealed,
    @required this.slots,
    @required this.resolvedWords,
  });
}

ThunkAction<AppState> initializeWordsInWord() {
  return (store) {
    store.dispatch(addBonusesToVerse());
    store.dispatch(initializeState());
    store.dispatch(_fillEmptySlots());
  };
}

ThunkAction<AppState> initializeState() {
  return (store) {
    final state = store.state.wordsInWord ?? WordsInWordState.emptyState();
    final wordsToFind = _extractWordsToFind(store.state.game.verse.words);
    var slots = _generateEmptySlots(wordsToFind);
    store.dispatch(UpdateWordsInWordState(state.copyWith(
      wordsToFind: wordsToFind,
      slots: slots,
      slotsBackup: slots,
      resolvedWords: [],
      proposition: [],
    )));
    store.dispatch(recomputeCells());
  };
}

ThunkAction<AppState> addBonusesToVerse() {
  return (store) {
    final verse = store.state.game.verse;
    final verseWithBonus = verse.copyWith(
      words: verse.words.map(_addRandomBonusToWord).toList(),
    );
    store.dispatch(UpdateGameVerse(verseWithBonus));
  };
}

Word _addRandomBonusToWord(Word word) {
  if (word.isSeparator) {
    return word;
  }
  final random = Random();
  int power = 1;
  if (word.chars.length > 1) {
    power += Random().nextInt((word.chars.length * 0.8).floor());
  }
  if (random.nextDouble() > 0.5) {
    return word.copyWith(bonus: RevealCharBonus(power, 0));
  }
  return word;
}

ThunkAction<AppState> _fillEmptySlots() {
  return (store) {
    final state = store.state.wordsInWord;
    final slots = fillSlots(state.slots, state.wordsToFind);
    store.dispatch(UpdateWordsInWordState(state.copyWith(
      slots: slots,
      slotsBackup: slots,
    )));
    store.dispatch(recomputeSlotsIndexes());
  };
}

List<Word> _extractWordsToFind(List<Word> words) {
  final List<Word> wordsToFind = [];
  for (final word in words) {
    if (!word.isSeparator &&
        !word.resolved &&
        wordsToFind.where((w) => w.sameAsChars(word.chars)).length == 0) {
      wordsToFind.add(word);
    }
  }
  return wordsToFind;
}

List<Char> fillSlots(List<Char> prevSlots, List<Word> words) {
  final random = Random();
  final targetLength = prevSlots.length;
  final slots = prevSlots.where((char) => char != null).toList();
  final freeSlots = targetLength - slots.length;
  final wordsCopy = List<Word>.from(words);
  final List<List<Char>> eligibleAdditionalChars = [];
  final List<List<Char>> otherAdditionalChars = [];
  var shortestAdditionalChars = prevSlots.length;
  var stillContainValidWord = false;

  for (int index = 0; index < wordsCopy.length; index++) {
    final additional = getAdditionalChars(words[index], slots);
    if (additional.length == 0) {
      stillContainValidWord = true;
    } else {
      if (additional.length <= freeSlots) {
        eligibleAdditionalChars.add(additional);
      } else {
        otherAdditionalChars.add(additional);
      }
      if (shortestAdditionalChars > additional.length) {
        shortestAdditionalChars = additional.length;
      }
    }
  }

  if (!stillContainValidWord &&
      eligibleAdditionalChars.length == 0 &&
      otherAdditionalChars.length > 0) {
    while ((targetLength - slots.length) < shortestAdditionalChars) {
      slots.removeLast();
    }
    for (int i = otherAdditionalChars.length - 1; i >= 0; i--) {
      if (otherAdditionalChars[i].length <= shortestAdditionalChars) {
        eligibleAdditionalChars.add(otherAdditionalChars[i]);
        otherAdditionalChars.removeAt(i);
      }
    }
  }

  while (eligibleAdditionalChars.length > 0 && slots.length < targetLength) {
    final randomIndex =
        (random.nextDouble() * random.nextInt(eligibleAdditionalChars.length)).floor();
    final additionalChars = eligibleAdditionalChars[randomIndex];
    eligibleAdditionalChars.removeAt(randomIndex);
    for (final char in additionalChars) {
      if (slots.length < targetLength) {
        slots.add(Char(
          value: char.comparisonValue.toUpperCase(),
          comparisonValue: char.comparisonValue,
        ));
      }
    }
  }

  if (slots.length < targetLength) {
    List<Word> otherWords = [];
    for (final word in wordsCopy) {
      final additional = getAdditionalChars(word, slots);
      if (additional.length > 0) {
        otherAdditionalChars.add(additional);
        otherWords.add(word);
      }
    }
    otherWords
        .sort((a, b) => getAdditionalChars(a, slots).length - getAdditionalChars(b, slots).length);

    if (otherWords.length > 0) {
      for (final word in otherWords) {
        final additional = getAdditionalChars(word, slots);
        for (final char in additional) {
          if (slots.length < targetLength) {
            slots.add(char.toSlotChar());
          } else {
            break;
          }
        }
        if (slots.length == targetLength) {
          break;
        }
      }
    }
  }
  return slots;
}

List<Char> _generateEmptySlots(List<Word> words) {
  final num = max(6, words.map((w) => w.chars.length).reduce((a, b) => max(a, b)));
  return List<Char>(num);
}

List<Char> getAdditionalChars(Word word, List<Char> slots) {
  final missingChars = List<Char>.from(word.chars);
  final slotsCopy = List<Char>.from(slots);
  for (int i = missingChars.length - 1; i >= 0; i--) {
    final matches =
        slotsCopy.where((char) => char.comparisonValue == missingChars[i].comparisonValue);
    final match = matches.length > 0 ? matches.first : null;
    if (match != null) {
      missingChars.removeAt(i);
      slotsCopy.remove(match);
    }
  }
  missingChars.shuffle();
  return missingChars;
}

ThunkAction<AppState> slotClickHandler(int index) {
  return (store) {
    final state = store.state.wordsInWord;
    final slots = List<Char>.from(state.slots);
    final proposition = List<Char>.from(state.proposition);
    proposition.add(slots[index]);
    slots[index] = null;
    store.dispatch(UpdateWordsInWordState(state.copyWith(
      slots: slots,
      proposition: proposition,
    )));
  };
}

ThunkAction<AppState> proposeWordsInWord() {
  return (Store<AppState> store) {
    final hasFoundMatch = propose(store);
    if (hasFoundMatch) {
      store.dispatch(_fillEmptySlots());
    }
  };
}

bool propose(Store<AppState> store) {
  final state = store.state.wordsInWord;
  final prevVerse = store.state.game.verse;
  final result = _getPropositionResult(state, prevVerse);
  final hasFoundMatch = result.hasFoundMatch;
  final wordsToFind = result.wordsToFind;
  final verse = result.verse;

  store.dispatch(UpdateWordsInWordState(state.copyWith(
    slots: result.slots,
    proposition: [],
    resolvedWords: result.resolvedWords,
    wordsToFind: wordsToFind,
  )));
  store.dispatch(UpdateGameVerse(verse));
  if (hasFoundMatch) {
    store.dispatch(incrementMoney(prevVerse, verse));
    store.dispatch(useBonus(result.revealed.bonus, false));
    store.dispatch(triggerPropositionSuccessAnimation());
    store.dispatch(playSuccessSfx(wordsToFind.length == 0));
  } else {
    store.dispatch(triggerPropositionFailureAnimation());
  }
  if (wordsToFind.length == 0) {
    // this means that the game is completed
    store.dispatch(InvalidateCombo());
    store.dispatch(UpdateGameResolvedState(true));
    store.dispatch(stopPropositionAnimation());
  }
  return hasFoundMatch;
}

ProposeResult _getPropositionResult(WordsInWordState state, BibleVerse verse) {
  final wordsToFind = List<Word>.from(state.wordsToFind);
  final resolvedWords = List<Word>.from(state.resolvedWords);
  final proposition = state.proposition;
  Word revealed;
  var slots = state.slots;
  bool hasFoundMatch = false;

  for (final word in state.wordsToFind) {
    if (word.sameAsChars(proposition)) {
      hasFoundMatch = true;
      resolvedWords.add(word.resolvedVersion);
      wordsToFind.remove(word);
      revealed = word;
    }
  }

  if (hasFoundMatch) {
    verse = _updateVerseResolvedWords(proposition, verse);
  } else {
    slots = state.slotsBackup;
  }

  return ProposeResult(
    verse: verse,
    slots: slots,
    revealed: revealed,
    wordsToFind: wordsToFind,
    resolvedWords: resolvedWords,
    hasFoundMatch: hasFoundMatch,
  );
}

BibleVerse _updateVerseResolvedWords(List<Char> proposition, BibleVerse verse) {
  final words = List<Word>.from(verse.words);
  for (int i = 0; i < words.length; i++) {
    final word = words[i];
    if (!word.resolved && word.sameAsChars(proposition)) {
      words[i] = word.copyWith(resolved: true);
    }
  }
  return verse.copyWith(words: words);
}

ThunkAction<AppState> shuffleSlotsAction() {
  return (Store<AppState> store) {
    final state = store.state.wordsInWord;
    final slotsBackup = List<Char>.from(state.slotsBackup)..shuffle();
    final slots = List<Char>.from(slotsBackup);
    final proposition = state.proposition;

    for (final char in proposition) {
      for (int slotIndex = 0; slotIndex < slotsBackup.length; slotIndex++) {
        if (char.comparisonValue == slots[slotIndex]?.comparisonValue) {
          slots[slotIndex] = null;
          break;
        }
      }
    }
    store.dispatch(UpdateWordsInWordState(state.copyWith(
      slots: slots,
      slotsBackup: slotsBackup,
    )));
  };
}
