import 'dart:math';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';

ThunkAction<AppState> initializeWordsInWordState = (Store<AppState> store) {
  final state = store.state.wordsInWord;
  final wordsToFind = state.verse.words.where((w) => !w.isSeparator).toList();
  var slots = generateEmptySlots(wordsToFind);
  slots = fillSlots(slots, wordsToFind);

  store.dispatch(UpdateWordsInWordState(state.copyWith(
    wordsToFind: wordsToFind,
    slots: slots,
    slotsBackup: slots,
    resolvedWords: [],
  )));
};

List<Char> generateEmptySlots(List<Word> words) {
  final num = max(6, words.map((w) => w.chars.length).reduce((a, b) => max(a, b)));
  return List<Char>(num);
}

List<Char> fillSlots(List<Char> prevSlots, List<Word> words) {
  final targetLength = prevSlots.length;
  final slots = prevSlots.where((char) => char != null).toList();
  final wordsCopy = List<Word>.from(words);
  bool canAdd = false;

  while (wordsCopy.length > 0 && slots.length < targetLength) {
    final wordIndex = Random().nextInt(wordsCopy.length);
    final word = wordsCopy[wordIndex];
    final additionalChars = getAdditionalChars(word, slots);
    if (!canAdd) {
      canAdd = targetLength >= slots.length + additionalChars.length;
    }
    if (canAdd) {
      wordsCopy.removeAt(wordIndex);
      for (final char in additionalChars) {
        if (slots.length < targetLength) {
          slots.add(Char(
            value: char.comparisonValue.toUpperCase(),
            comparisonValue: char.comparisonValue,
          ));
        }
      }
    }
  }

  if (slots.length < targetLength) {
    final allChars = words.map((w) => w.chars).reduce((a, b) => [a, b].expand((x) => x).toList()).toList();
    for (final char in allChars) {
      final matchesInWords = allChars.where((c) => c.comparisonValue == char.comparisonValue).length;
      var matchesInSlots = slots.where((c) => c.comparisonValue == char.comparisonValue).length;
      while (matchesInWords > matchesInSlots && slots.length < targetLength) {
        matchesInSlots++;
        slots.add(Char(value: char.comparisonValue.toUpperCase(), comparisonValue: char.comparisonValue));
      }
      if (slots.length == targetLength) {
        break;
      }
    }
  }

  return slots;
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
