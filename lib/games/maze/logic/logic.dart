import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/app/inventory/actions/bonus.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/logic/bonus.dart';
import 'package:bible_game/games/maze/logic/paths.dart';
import 'package:bible_game/games/maze/logic/reveal.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/models/word.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> proposeMaze(List<Coordinate> cellCoordinates) {
  return (store) async {
    final state = store.state.maze;
    final board = state.board;
    final words = state.words;
    final oldRevealed = state.revealed;
    final cells = cellCoordinates.map((c) => board.getAt(c.x, c.y)).toList();
    final revealedWord = getRevealedWord(cells, state.words);
    if (revealedWord != null) {
      final revealed = reveal(cellCoordinates, state.revealed);
      if (_isCompleted(board, words, revealed)) {
        store.dispatch(UpdateGameResolvedState(true));
        store.state.sfx.playLongSuccess();
      } else {
        final paths = getRevealedPaths(state.board, revealed, state.words);
        store.dispatch(UpdateMazeState(state.copyWith(
          revealed: revealed,
          paths: paths,
          newlyRevealed: cellCoordinates,
        )));
        store.dispatch(updatedWordsToReveal());
        store.dispatch(updateWordsToConfirm());
        store.dispatch(useBonus(revealedWord.bonus, false));
        store.dispatch(updateNewlyRevealed(oldRevealed));
        store.dispatch(updatedWordsToReveal());
        store.state.sfx.playShortSuccess();

        await Future.delayed(Duration(milliseconds: 600));
        store.dispatch(invalidateNewlyRevealed());
      }
    }
  };
}

bool _isCompleted(Board board, List<Word> words, List<List<bool>> revealed) {
  for (var wordIndex = 0; wordIndex < words.length; wordIndex++) {
    for (var charIndex = 0; charIndex < words[wordIndex].length; charIndex++) {
      final position = board.coordinateOf(wordIndex, charIndex);
      if (!revealed[position.y][position.x]) {
        return false;
      }
    }
  }
  return true;
}
