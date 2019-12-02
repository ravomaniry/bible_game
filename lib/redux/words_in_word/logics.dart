import 'dart:math';

import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:bible_game/redux/words_in_word/cells_action.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> initializeWordsInWordState = (Store<AppState> store) {
  final state = store.state.wordsInWord;
  final wordsToFind = extractWordsToFind(state.verse.words);
  var slots = generateEmptySlots(wordsToFind);
  slots = fillSlots(slots, wordsToFind);
  store.dispatch(UpdateWordsInWordState(state.copyWith(
    wordsToFind: wordsToFind,
    slots: slots,
    slotsBackup: slots,
    resolvedWords: [],
  )));
  store.dispatch(recomputeSlotsIndexes);
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

List<Char> fillSlots(List<Char> prevSlots, List<Word> words) {
  final targetLength = prevSlots.length;
  final slots = prevSlots.where((char) => char != null).toList();
  final remainingSlots = targetLength - slots.length;
  final wordsCopy = List<Word>.from(words);
  final List<List<Char>> eligibleAdditionalChars = [];
  List<List<Char>> otherAdditionalChars = [];
  var shortestAdditionalChars = slots.length;

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

  if (eligibleAdditionalChars.length == 0) {
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
    final randomIndex = Random().nextInt(eligibleAdditionalChars.length);
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

class SlotClickHandler {
  final int _index;
  ThunkAction<AppState> thunk;

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
  var verse = state.verse;
  var slots = List<Char>.from(state.slots);
  var slotsBackup = List<Char>.from(state.slotsBackup);
  bool hasFoundMatch = false;

  for (final word in state.wordsToFind) {
    if (word.sameAsChars(proposition)) {
      hasFoundMatch = true;
      resolvedWords.add(word);
      wordsToFind.remove(word);
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
    verse: verse,
    slots: slots,
    proposition: [],
    slotsBackup: slotsBackup,
    resolvedWords: resolvedWords,
    wordsToFind: wordsToFind,
  )));
  store.dispatch(recomputeSlotsIndexes);
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
