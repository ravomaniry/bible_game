import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/reducer.dart';
import 'package:bible_game/redux/db/reducer.dart';
import 'package:bible_game/redux/editor/reducer.dart';
import 'package:bible_game/redux/error/reducer.dart';
import 'package:bible_game/redux/explorer/reducer.dart';
import 'package:bible_game/redux/game/reducer.dart';
import 'package:bible_game/redux/quit_single_game_dialog/reducer.dart';
import 'package:bible_game/redux/router/reducer.dart';
import 'package:bible_game/redux/themes/reducer.dart';
import 'package:bible_game/redux/words_in_word/reducer.dart';

AppState mainReducer(AppState state, action) {
  return AppState(
    dba: state.dba,
    sfx: state.sfx,
    editor: editorReducer(state.editor, action),
    theme: themeReducer(state.theme, action),
    assetBundle: state.assetBundle,
    config: configReducer(state.config, action),
    error: errorReducer(state.error, action),
    route: routerReducer(state.route, action),
    dbIsReady: dbReducer(state.dbIsReady, action),
    game: gamesListStateReducer(state.game, action),
    explorer: explorerReducer(state.explorer, action),
    wordsInWord: wordsInWordReducer(state.wordsInWord, action),
    quitSingleGameDialog: quitSingleGameDialogReducer(state.quitSingleGameDialog, action),
  );
}
