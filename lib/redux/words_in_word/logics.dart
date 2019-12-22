import 'dart:math';

import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/models/thunk_container.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/game/actions.dart';
import 'package:bible_game/redux/inventory/actions.dart';
import 'package:bible_game/redux/inventory/use_bonus_action.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:bible_game/redux/words_in_word/cells_action.dart';
import 'package:bible_game/redux/words_in_word/state.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> initializeWordsInWordState = (Store<AppState> store) {
  final state = store.state.wordsInWord ?? WordsInWordState.emptyState();
  final verse = store.state.game.verse;
  final verseWithBonus = verse.copyWith(
    words: verse.words.map(addRandomBonusToWord).toList(),
  );
  final wordsToFind = extractWordsToFind(verseWithBonus.words);
  var slots = generateEmptySlots(wordsToFind);
  slots = fillSlots(slots, wordsToFind);
  store.dispatch(UpdateGameVerse(verseWithBonus));
  store.dispatch(UpdateWordsInWordState(state.copyWith(
    wordsToFind: wordsToFind,
    slots: slots,
    slotsBackup: slots,
    resolvedWords: [],
  )));
  store.dispatch(recomputeSlotsIndexes);
  store.dispatch(recomputeCells);
  store.dispatch(GoToAction(Routes.wordsInWord));
};

List<Word> extractWordsToFind(List<Word> words) {
  final List<Word> wordsToFind = [];
  for (final word in words) {
    if (!word.isSeparator && wordsToFind.where((w) => w.sameAsChars(word.chars)).length == 0) {
      wordsToFind.add(word);
    }
  }
  return wordsToFind;
}

Word addRandomBonusToWord(Word word) {
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

List<Char> fillSlots(List<Char> prevSlots, List<Word> words) {
  final random = Random();
  final targetLength = prevSlots.length;
  final slots = prevSlots.where((char) => char != null).toList();
  final remainingSlots = targetLength - slots.length;
  final wordsCopy = List<Word>.from(words);
  final List<List<Char>> eligibleAdditionalChars = [];
  List<List<Char>> otherAdditionalChars = [];
  var shortestAdditionalChars = prevSlots.length;

  for (int index = 0; index < wordsCopy.length; index++) {
    final additional = getAdditionalChars(words[index], slots);
    if (additional.length > 0) {
      if (additional.length <= remainingSlots) {
        eligibleAdditionalChars.add(additional);
      } else {
        otherAdditionalChars.add(additional);
      }
      if (shortestAdditionalChars > additional.length) {
        shortestAdditionalChars = additional.length;
      }
    }
  }

  if (eligibleAdditionalChars.length == 0 && otherAdditionalChars.length > 0) {
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
    final randomIndex = (random.nextDouble() * random.nextInt(eligibleAdditionalChars.length)).floor();
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
    otherWords.sort((a, b) => getAdditionalChars(a, slots).length - getAdditionalChars(b, slots).length);

    if (otherWords.length > 0) {
      for (final word in otherWords) {
        final additional = getAdditionalChars(word, slots);
        for (final char in additional) {
          if (slots.length < targetLength) {
            slots.add(Char(value: char.comparisonValue.toUpperCase(), comparisonValue: char.comparisonValue));
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

List<Char> generateEmptySlots(List<Word> words) {
  final num = max(6, words.map((w) => w.chars.length).reduce((a, b) => max(a, b)));
  return List<Char>(num);
}

List<Char> getAdditionalChars(Word word, List<Char> slots) {
  final missingChars = List<Char>.from(word.chars);
  final slotsCopy = List<Char>.from(slots);
  for (int i = missingChars.length - 1; i >= 0; i--) {
    final matches = slotsCopy.where((char) => char.comparisonValue == missingChars[i].comparisonValue);
    final match = matches.length > 0 ? matches.first : null;
    if (match != null) {
      missingChars.removeAt(i);
      slotsCopy.remove(match);
    }
  }
  missingChars.shuffle();
  return missingChars;
}

class SlotClickHandler extends ThunkContainer {
  final int _index;

  SlotClickHandler(this._index) {
    thunk = (Store<AppState> store) {
      final state = store.state.wordsInWord;
      final slots = List<Char>.from(state.slots);
      final proposition = List<Char>.from(state.proposition);
      proposition.add(slots[_index]);
      slots[_index] = null;
      store.dispatch(UpdateWordsInWordState(state.copyWith(
        slots: slots,
        proposition: proposition,
      )));
    };
  }
}

ThunkAction<AppState> proposeWordsInWord = (Store<AppState> store) {
  final state = store.state.wordsInWord;
  final wordsToFind = List<Word>.from(state.wordsToFind);
  final resolvedWords = List<Word>.from(state.resolvedWords);
  final proposition = state.proposition;
  Word revealed;
  var verse = store.state.game.verse;
  final prevVerse = verse;
  var slots = List<Char>.from(state.slots);
  var slotsBackup = List<Char>.from(state.slotsBackup);
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
    slots = fillSlots(slots, wordsToFind);
    slotsBackup = slots;
    verse = updateVerseResolvedWords(proposition, verse);
  } else {
    slots = slotsBackup;
  }

  store.dispatch(UpdateWordsInWordState(state.copyWith(
    slots: slots,
    proposition: [],
    slotsBackup: slotsBackup,
    resolvedWords: resolvedWords,
    wordsToFind: wordsToFind,
  )));
  store.dispatch(UpdateGameVerse(verse));
  store.dispatch(recomputeSlotsIndexes);
  if (hasFoundMatch) {
    store.dispatch(IncrementMoney(prevVerse, verse).thunk);
    store.dispatch(UseBonus(revealed.bonus, false).thunk);
    store.dispatch(triggerPropositionSuccessAnimation);
  } else {
    store.dispatch(triggerPropositionFailureAnimation);
  }
  // wordsToFind.length == 0 this means that the game is completed
  if (wordsToFind.length == 0) {
    store.dispatch(InvalidateCombo());
    store.dispatch(UpdateGameResolvedState(true));
    store.dispatch(stopPropositionAnimation);
  }
};

BibleVerse updateVerseResolvedWords(List<Char> proposition, BibleVerse verse) {
  final words = List<Word>.from(verse.words);
  for (int i = 0; i < words.length; i++) {
    final word = words[i];
    if (!word.resolved && word.sameAsChars(proposition)) {
      words[i] = word.copyWith(resolved: true);
    }
  }
  return verse.copyWith(words: words);
}

ThunkAction<AppState> shuffleSlotsAction = (Store<AppState> store) {
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
