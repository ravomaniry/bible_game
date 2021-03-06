import 'dart:math';

import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> addBonusesToVerse({@required double probability, @required double power}) {
  return (store) {
    final verse = store.state.game.verse;
    store.dispatch(UpdateGameVerse(verse.copyWith(
      words: verse.words.map((w) => _addRandomBonusToWord(w, probability, power)).toList(),
    )));
  };
}

Word _addRandomBonusToWord(Word word, double probability, double power) {
  final bonusRatio = 1.5;
  final probability = 0.6;
  if (word.isSeparator) {
    return word;
  }
  final random = Random();
  int power = 1;
  if (word.chars.length > 1) {
    power += Random().nextInt((word.chars.length * bonusRatio).floor());
  }
  if (random.nextDouble() < probability) {
    return word.copyWith(bonus: RevealCharBonus(power, 0));
  }
  return word;
}

bool useBonusInWordsInWord(Bonus bonus, Store<AppState> store) {
  if (bonus is RevealCharBonus) {
    var verse = store.state.game.verse;
    final random = Random();
    final charValidator = (Char char) => !char.resolved;
    final wordValidator = (Word word) {
      return !word.isSeparator && !word.resolved && word.chars.where(charValidator).length > 1;
    };

    for (int bonusPower = bonus.power; bonusPower > 0; bonusPower--) {
      int wordStartingIndex = random.nextInt(verse.words.length);
      final wordIndex = findNearestElement(verse.words, wordStartingIndex, wordValidator);
      if (wordIndex != null) {
        final word = verse.words[wordIndex];
        final charStaringIndex = random.nextInt(word.chars.length);
        final charIndex = findNearestElement(word.chars, charStaringIndex, charValidator);
        final copy = word.copyWithChar(charIndex, word.chars[charIndex].copyWith(resolved: true));
        final words = List<Word>.from(verse.words)..[wordIndex] = copy;
        verse = verse.copyWith(words: words);
      }
    }
    if (verse != store.state.game.verse) {
      store.dispatch(UpdateGameVerse(verse));
      return true;
    }
  }
  return false;
}

int findNearestElement<T>(List<T> list, int startingIndex, Function(T) validator) {
  int minIndex = startingIndex;
  int maxIndex = startingIndex + 1;
  while (minIndex >= 0 || maxIndex < list.length) {
    if (minIndex >= 0 && validator(list[minIndex])) {
      return minIndex;
    } else if (maxIndex < list.length && validator(list[maxIndex])) {
      return maxIndex;
    }
    minIndex--;
    maxIndex++;
  }
  return null;
}
