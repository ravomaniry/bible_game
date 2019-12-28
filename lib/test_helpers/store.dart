import 'package:bible_game/models/game_mode.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/editor/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/game/lists_handler.dart';
import 'package:bible_game/redux/game/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:bible_game/redux/words_in_word/logics.dart';
import 'package:bible_game/redux/words_in_word/state.dart';
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
    dbIsReady: false,
    error: null,
    quitSingleGameDialog: false,
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
