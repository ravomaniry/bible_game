import 'dart:math';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/inventory/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:redux/redux.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/models/thunk_container.dart';
import 'package:bible_game/redux/app_state.dart';

class UseBonus extends ThunkContainer {
  final Bonus _bonus;
  final bool _triggeredByUser;

  UseBonus(this._bonus, this._triggeredByUser) {
    this.thunk = (Store<AppState> store) {
      final isUsed = useBonus(store);
      if (_triggeredByUser && isUsed) {
        store.dispatch(DecrementBonus(_bonus));
      }
    };
  }

  bool useBonus(Store<AppState> store) {
    if (store.state.route == Routes.wordsInWord) {
      return useBonusInWordsInWord(_bonus, store);
    }
    return false;
  }
}

bool useBonusInWordsInWord(Bonus bonus, Store<AppState> store) {
  if (bonus is RevealCharBonus) {
    var verse = store.state.wordsInWord.verse;
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
    if (verse != store.state.wordsInWord.verse) {
      store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(verse: verse)));
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
