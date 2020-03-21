import 'dart:math';

import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/app/inventory/actions/actions.dart';
import 'package:bible_game/app/inventory/actions/bonus.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/words_in_word/actions/action_creators.dart';
import 'package:bible_game/games/words_in_word/actions/bonus.dart';
import 'package:bible_game/games/words_in_word/actions/cells_action.dart';
import 'package:bible_game/games/words_in_word/reducer/state.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/sfx/actions.dart';
import 'package:bible_game/utils/pair.dart';
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
  final int deltaMoney;
  final List<Coordinate> newlyRevealed;

  ProposeResult({
    @required this.verse,
    @required this.hasFoundMatch,
    @required this.wordsToFind,
    @required this.revealed,
    @required this.slots,
    @required this.resolvedWords,
    @required this.deltaMoney,
    @required this.newlyRevealed,
  });
}

ThunkAction<AppState> initializeWordsInWord() {
  return (store) {
    store.dispatch(addBonusesToVerse(probability: 0.5, power: 2));
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
      newlyRevealed: [],
    )));
    store.dispatch(recomputeCells());
  };
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
    otherWords.sort(
      (a, b) => getAdditionalChars(a, slots).length - getAdditionalChars(b, slots).length,
    );

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
  return (Store<AppState> store) async {
    final hasFoundMatch = propose(store);
    if (hasFoundMatch) {
      store.dispatch(_fillEmptySlots());
      await Future.delayed(Duration(milliseconds: 500));
      store.dispatch(_invalidateNewlyRevealed());
      store.dispatch(stopPropositionAnimation());
    }
  };
}

bool propose(Store<AppState> store) {
  final state = store.state.wordsInWord;
  final prevVerse = store.state.game.verse;
  final result = _getPropositionResult(state, prevVerse);
  final hasFoundMatch = result.hasFoundMatch;
  final wordsToFind = result.wordsToFind;

  store.dispatch(UpdateGameVerse(result.verse));
  store.dispatch(UpdateWordsInWordState(state.copyWith(
    slots: result.slots,
    proposition: [],
    resolvedWords: result.resolvedWords,
    wordsToFind: wordsToFind,
    newlyRevealed: result.newlyRevealed,
  )));
  if (hasFoundMatch) {
    store.dispatch(incrementMoney(result.deltaMoney));
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
  var deltaMoney = 0;
  bool hasFoundMatch = false;

  for (final word in state.wordsToFind) {
    if (word.sameAsChars(proposition)) {
      hasFoundMatch = true;
      resolvedWords.add(word.resolvedVersion);
      wordsToFind.remove(word);
      revealed = word;
    }
  }

  final revealedCells = List<Cell>();
  if (hasFoundMatch) {
    final updated = _updateVerseResolvedWords(proposition, verse, revealedCells);
    verse = updated.first;
    deltaMoney = updated.last;
  } else {
    slots = state.slotsBackup;
  }
  final newlyRevealed = _getCellsCoordinates(revealedCells, state.cells);

  return ProposeResult(
    verse: verse,
    slots: slots,
    revealed: revealed,
    deltaMoney: deltaMoney,
    wordsToFind: wordsToFind,
    resolvedWords: resolvedWords,
    hasFoundMatch: hasFoundMatch,
    newlyRevealed: newlyRevealed,
  );
}

Pair<BibleVerse, int> _updateVerseResolvedWords(
  List<Char> proposition,
  BibleVerse verse,
  List<Cell> revealedCells,
) {
  var deltaMoney = 0;
  final words = List<Word>.from(verse.words);
  for (int wIndex = 0; wIndex < words.length; wIndex++) {
    final word = words[wIndex];
    if (!word.resolved && word.sameAsChars(proposition)) {
      words[wIndex] = word.copyWith(resolved: true);
      deltaMoney += word.chars.where((c) => !c.resolved).length;
      for (var cIndex = 0; cIndex < word.length; cIndex++) {
        revealedCells.add(Cell(wIndex, cIndex));
      }
    }
  }
  return Pair(verse.copyWith(words: words), deltaMoney);
}

List<Coordinate> _getCellsCoordinates(List<Cell> cells, List<List<Cell>> positions) {
  final coordinates = List<Coordinate>();
  for (final cell in cells) {
    for (var y = 0; y < positions.length; y++) {
      for (var x = 0; x < positions[y].length; x++) {
        if (cell == positions[y][x]) {
          coordinates.add(Coordinate(x, y));
        }
      }
    }
  }
  return coordinates;
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

ThunkAction<AppState> _invalidateNewlyRevealed() {
  return (store) {
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(newlyRevealed: [])));
  };
}
