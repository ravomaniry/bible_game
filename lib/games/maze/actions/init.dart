import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/actions/create_board.dart';
import 'package:bible_game/games/maze/redux/state.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> initMaze() {
  return (store) async {
    final state = store.state.maze ?? MazeState.emptyState();
    final verse = store.state.game.verse;
    final wordsToFind = getWordsInScopeForMaze(verse);
    final board = await createMazeBoard(verse);

    store.dispatch(UpdateMazeState(state.copyWith(
      board: board,
      wordsToFind: wordsToFind,
    )));
  };
}
