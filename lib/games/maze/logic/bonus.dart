import 'dart:math';

import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
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
  if (toReveal.isNotEmpty || toReveal.isNotEmpty) {
    final rand = Random();
    final wordIndex =
        toReveal.isEmpty ? getRandomElement(toConfirm, rand) : getRandomElement(toReveal, rand);
    store.dispatch(_revealChars(bonus, wordIndex, rand));
    store.dispatch(_confirmChars(bonus, wordIndex, rand));
    return true;
  }
  return false;
}

ThunkAction<AppState> _revealChars(Bonus bonus, int wordIndex, Random rand) {
  return (store) {
    final toReveal = store.state.maze.wordsToReveal;
    final word = store.state.maze.words[wordIndex];
    final board = store.state.maze.board;
    var revealed = store.state.maze.revealed;
    if (toReveal.contains(wordIndex)) {
      final charIndexes = _getUnrevealedCharIndexes(word, wordIndex, board, revealed);
      revealed = _revealRandomChars(bonus, wordIndex, charIndexes, revealed, board, rand);
      store.dispatch(UpdateMazeState(store.state.maze.copyWith(revealed: revealed)));
      store.dispatch(updatedWordsToReveal([board.coordinateOf(wordIndex, 0)]));
    }
  };
}

ThunkAction<AppState> _confirmChars(Bonus bonus, int wordIndex, Random rand) {
  return (store) {
    final state = store.state.maze;
    final word = state.words[wordIndex];
    final board = state.board;
    final confirmed = List<Coordinate>.from(state.confirmed);
    var power = (bonus.point / 8).round();
    if (power > 0) {
      final charIndexes = _getUnconfirmedCharIndexes(word, wordIndex, board, confirmed);
      while (power > 0 && charIndexes.isNotEmpty) {
        final charIndex = getRandomElement(charIndexes, rand);
        confirmed.add(board.coordinateOf(wordIndex, charIndex));
        power--;
      }
      store.dispatch(updateWordsToConfirm());
    }
  };
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
  Bonus bonus,
  int wordIndex,
  List<int> charIndexes,
  List<List<bool>> revealed,
  Board board,
  Random rand,
) {
  revealed = revealed.map((x) => [...x]).toList();
  for (var power = bonus.point; power > 0 && charIndexes.length > 1; power--) {
    final charIndex = getRandomElement(charIndexes, rand);
    final point = board.coordinateOf(wordIndex, charIndex);
    revealed[point.y][point.x] = true;
  }
  return revealed;
}

ThunkAction<AppState> updatedWordsToReveal(List<Coordinate> newlyRevealed) {
  return (store) {
    final state = store.state.maze;
    final words = state.words;
    final wordsToFind = List<int>.from(state.wordsToReveal);
    final indexes = _getWordIndexesAt(newlyRevealed, state.board);
    for (final index in indexes) {
      if (_getUnrevealedCharIndexes(words[index], index, state.board, state.revealed).length < 2) {
        wordsToFind.remove(index);
      }
    }
    if (wordsToFind.length != state.wordsToReveal.length) {
      store.dispatch(UpdateMazeState(state.copyWith(wordsToFind: wordsToFind)));
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
    for (final index in toConfirm) {
      if (_getUnconfirmedCharIndexes(words[index], index, state.board, state.confirmed).isEmpty) {
        toConfirm.remove(index);
      }
    }
    if (toConfirm.length != state.wordsToConfirm.length) {
      store.dispatch(UpdateMazeState(state.copyWith(wordsToFind: toConfirm)));
    }
  };
}
