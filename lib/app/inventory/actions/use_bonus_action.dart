import 'dart:math';

import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/app/inventory/actions/actions.dart';
import 'package:bible_game/app/router/routes.dart';
import 'package:bible_game/sfx/actions.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> useBonus(Bonus bonus, bool isTriggeredByUser) {
  return (store) {
    final isUsed = _useBonusInActiveGame(bonus, store);
    if (isTriggeredByUser && isUsed) {
      store.dispatch(DecrementBonus(bonus));
    }
    if (isUsed) {
      store.dispatch(playBonusSfx());
    }
  };
}

bool _useBonusInActiveGame(Bonus _bonus, Store<AppState> store) {
  if (store.state.route == Routes.wordsInWord || store.state.route == Routes.anagram) {
    return useBonusInWordsInWord(_bonus, store);
  }
  return false;
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