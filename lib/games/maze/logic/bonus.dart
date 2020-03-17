import 'dart:math';

import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/logic/paths.dart';
import 'package:bible_game/games/maze/logic/reveal.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/utils/random.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

bool useBonusInMaze(Bonus bonus, Store<AppState> store) {
  final state = store.state.maze;
  final toReveal = state.wordsToReveal;
  final toConfirm = state.wordsToConfirm;
  final oldRevealed = state.revealed;
  if (bonus is RevealCharBonus && (toReveal.isNotEmpty || toConfirm.isNotEmpty)) {
    final rand = Random();
    final wordIndex =
        toReveal.isEmpty ? getRandomElement(toConfirm, rand) : getRandomElement(toReveal, rand);
    final usedWithHint = _updateHints(bonus, wordIndex, rand, store);
    final usedToConfirm = _confirmChars(bonus, wordIndex, rand, store);
    if (usedWithHint || usedToConfirm) {
      store.dispatch(updateNewlyRevealed(oldRevealed));
      store.dispatch(updatedWordsToReveal());
      store.dispatch(updatePaths());
      store.dispatch(scheduleInvalidateNewlyRevealed());
      store.dispatch(updateGameVerseRevealedState());
      return true;
    }
  }
  return false;
}

bool _updateHints(RevealCharBonus bonus, int wordIndex, Random rand, Store<AppState> store) {
  final toReveal = store.state.maze.wordsToReveal;
  final word = store.state.maze.words[wordIndex];
  final board = store.state.maze.board;
  final hints = store.state.maze.hints;
  final revealed = store.state.maze.revealed;
  if (toReveal.contains(wordIndex)) {
    final charIndexes = _getUnrevealedCharIndexes(word, wordIndex, board, revealed, hints);
    final nextHints = _revealRandomHints(bonus, wordIndex, charIndexes, board, hints, rand);
    if (nextHints.length > hints.length) {
      store.dispatch(UpdateMazeState(store.state.maze.copyWith(hints: nextHints)));
      return true;
    }
  }
  return false;
}

bool _confirmChars(RevealCharBonus bonus, int wordIndex, Random rand, Store<AppState> store) {
  final state = store.state.maze;
  final word = state.words[wordIndex];
  final board = state.board;
  final confirmed = List<Coordinate>.from(state.confirmed);
  var power = (bonus.power / 5).round();
  if (power > 0) {
    final charIndexes = _getUnconfirmedCharIndexes(word, wordIndex, board, confirmed);
    while (power > 0 && charIndexes.isNotEmpty) {
      final charIndex = getRandomElement(charIndexes, rand);
      confirmed.add(board.coordinateOf(wordIndex, charIndex));
      power--;
    }
    store.dispatch(UpdateMazeState(state.copyWith(confirmed: confirmed)));
    store.dispatch(updateWordsToConfirm());
    return true;
  }
  return false;
}

List<int> _getUnrevealedCharIndexes(
  Word word,
  int wordIndex,
  Board board,
  List<List<bool>> revealed,
  List<Coordinate> hints,
) {
  final charIndexes = List<int>();
  for (var i = 0, max = word.length; i < max; i++) {
    final point = board.coordinateOf(wordIndex, i);
    if (point != board.start &&
        point != board.end &&
        !revealed[point.y][point.x] &&
        !hints.contains(point)) {
      charIndexes.add(i);
    }
  }
  return charIndexes;
}

List<int> _getUnconfirmedCharIndexes(
  Word word,
  int wordIndex,
  Board board,
  List<Coordinate> confirmed,
) {
  final charIndexes = List<int>();
  for (var i = 0, max = word.length; i < max; i++) {
    final point = board.coordinateOf(wordIndex, i);
    if (point != board.start && point != board.end && !confirmed.contains(point)) {
      charIndexes.add(i);
    }
  }
  return charIndexes;
}

List<Coordinate> _revealRandomHints(
  RevealCharBonus bonus,
  int wordIndex,
  List<int> charIndexes,
  Board board,
  List<Coordinate> hints,
  Random rand,
) {
  charIndexes = [...charIndexes];
  hints = [...hints];
  for (var power = bonus.power; power > 0 && charIndexes.length > 1; power--) {
    final charIndex = getRandomElement(charIndexes, rand);
    final point = board.coordinateOf(wordIndex, charIndex);
    if (!hints.contains(point)) {
      hints.add(point);
    }
    charIndexes.remove(charIndex);
  }
  return hints;
}

ThunkAction<AppState> updatedWordsToReveal() {
  return (store) {
    final state = store.state.maze;
    final newlyRevealed = state.newlyRevealed;
    final words = state.words;
    final revealed = state.revealed;
    final hints = state.hints;
    final board = state.board;
    final wordsToReveal = List<int>.from(state.wordsToReveal);
    final indexes = getWordIndexesAt(newlyRevealed, board);
    for (final index in indexes) {
      if (_getUnrevealedCharIndexes(words[index], index, board, revealed, hints).length < 2) {
        wordsToReveal.remove(index);
      }
    }
    if (wordsToReveal.length != state.wordsToReveal.length) {
      store.dispatch(UpdateMazeState(state.copyWith(wordsToFind: wordsToReveal)));
    }
  };
}

List<int> getWordIndexesAt(List<Coordinate> points, Board board) {
  final List<int> wordIndexes = [];
  for (final point in points) {
    for (final cell in board.getAt(point.x, point.y).cells) {
      if (cell.wordIndex >= 0 && !wordIndexes.contains(cell.wordIndex)) {
        wordIndexes.add(cell.wordIndex);
      }
    }
  }
  return wordIndexes;
}

ThunkAction<AppState> updateWordsToConfirm() {
  return (store) {
    final state = store.state.maze;
    final words = state.words;
    final toConfirm = List<int>.from(state.wordsToConfirm);
    for (var i = toConfirm.length - 2; i >= 0; i--) {
      final wordIndex = toConfirm[i];
      final unconfirmedChars = _getUnconfirmedCharIndexes(
        words[wordIndex],
        wordIndex,
        state.board,
        state.confirmed,
      );
      if (unconfirmedChars.isEmpty) {
        toConfirm.removeAt(i);
      }
    }
    if (toConfirm.length != state.wordsToConfirm.length) {
      store.dispatch(UpdateMazeState(state.copyWith(wordsToConfirm: toConfirm)));
    }
  };
}

ThunkAction<AppState> updateHints(List<Coordinate> points) {
  return (store) {
    final hints = store.state.maze.hints.where((p) => !points.contains(p)).toList();
    store.dispatch(UpdateMazeState(store.state.maze.copyWith(hints: hints)));
  };
}
