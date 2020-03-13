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
    final usedToReveal = _revealChars(bonus, wordIndex, rand, store);
    final usedToConfirm = _confirmChars(bonus, wordIndex, rand, store);
    if (usedToReveal || usedToConfirm) {
      store.dispatch(updateNewlyRevealed(oldRevealed));
      store.dispatch(updatedWordsToReveal());
      store.dispatch(updatePaths());
      store.dispatch(scheduleInvalidateNewlyRevealed());
      return true;
    }
  }
  return false;
}

bool _revealChars(RevealCharBonus bonus, int wordIndex, Random rand, Store<AppState> store) {
  final toReveal = store.state.maze.wordsToReveal;
  final word = store.state.maze.words[wordIndex];
  final board = store.state.maze.board;
  final revealed = store.state.maze.revealed;
  if (toReveal.contains(wordIndex)) {
    final charIndexes = _getUnrevealedCharIndexes(word, wordIndex, board, revealed);
    final nextRevealed = _revealRandomChars(bonus, wordIndex, charIndexes, revealed, board, rand);
    store.dispatch(UpdateMazeState(store.state.maze.copyWith(revealed: nextRevealed)));
    return true;
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
) {
  final charIndexes = List<int>();
  for (var i = 0, max = word.length; i < max; i++) {
    final point = board.coordinateOf(wordIndex, i);
    if (!revealed[point.y][point.x]) {
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
    if (!confirmed.contains(board.coordinateOf(wordIndex, i))) {
      charIndexes.add(i);
    }
  }
  return charIndexes;
}

List<List<bool>> _revealRandomChars(
  RevealCharBonus bonus,
  int wordIndex,
  List<int> charIndexes,
  List<List<bool>> revealed,
  Board board,
  Random rand,
) {
  charIndexes = [...charIndexes];
  revealed = revealed.map((x) => [...x]).toList();
  for (var power = bonus.power; power > 0 && charIndexes.length > 1; power--) {
    final charIndex = getRandomElement(charIndexes, rand);
    final point = board.coordinateOf(wordIndex, charIndex);
    revealed[point.y][point.x] = true;
    charIndexes.remove(charIndex);
  }
  return revealed;
}

ThunkAction<AppState> updatedWordsToReveal() {
  return (store) {
    final state = store.state.maze;
    final newlyRevealed = state.newlyRevealed;
    final words = state.words;
    final wordsToReveal = List<int>.from(state.wordsToReveal);
    final indexes = _getWordIndexesAt(newlyRevealed, state.board);
    for (final index in indexes) {
      if (_getUnrevealedCharIndexes(words[index], index, state.board, state.revealed).length < 2) {
        wordsToReveal.remove(index);
      }
    }
    if (wordsToReveal.length != state.wordsToReveal.length) {
      store.dispatch(UpdateMazeState(state.copyWith(wordsToFind: wordsToReveal)));
    }
  };
}

List<int> _getWordIndexesAt(List<Coordinate> points, Board board) {
  final List<int> wordIndexes = [];
  for (final point in points) {
    for (final cell in board.getAt(point.x, point.y).cells) {
      if (cell.wordIndex >= 0 && !wordIndexes.contains(cell)) {
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
