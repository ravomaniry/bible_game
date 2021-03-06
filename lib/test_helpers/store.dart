import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/config/state.dart';
import 'package:bible_game/app/explorer/state.dart';
import 'package:bible_game/app/game/actions/lists_handler.dart';
import 'package:bible_game/app/game/reducer/state.dart';
import 'package:bible_game/app/game_editor/reducer/state.dart';
import 'package:bible_game/app/main_reducer.dart';
import 'package:bible_game/app/router/routes.dart';
import 'package:bible_game/app/texts.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/actions/init.dart';
import 'package:bible_game/games/maze/redux/state.dart';
import 'package:bible_game/games/words_in_word/actions/logics.dart';
import 'package:bible_game/games/words_in_word/reducer/state.dart';
import 'package:bible_game/models/game_mode.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:bible_game/test_helpers/sfx_mock.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

Store<AppState> newMockedStore() {
  final state = AppState(
    theme: AppColorTheme(),
    game: GameState.emptyState(),
    editor: EditorState(),
    sfx: SfxMock(),
    dba: DbAdapterMock.withDefaultValues(),
    assetBundle: AssetBundleMock.withDefaultValue(),
    config: ConfigState.initialState(),
    explorer: ExplorerState(),
    route: Routes.home,
    wordsInWord: WordsInWordState.emptyState(),
    error: null,
    quitSingleGameDialog: false,
    maze: MazeState.emptyState(),
    texts: AppTexts(),
  );
  final store = Store<AppState>(
    mainReducer,
    initialState: state,
    middleware: [thunkMiddleware],
  );
  return store;
}

void simulateWorInWordAsRandomGame(Store<AppState> store) {
  store.dispatch(initializeGame(GameMode(
    Routes.wordsInWord,
    initializeWordsInWord,
    BlueGrayTheme(),
  )));
}

void simulateMazeRandomGame(Store<AppState> store) {
  store.dispatch(initializeGame(GameMode(
    Routes.maze,
    initMaze,
    AppColorTheme(),
  )));
}
