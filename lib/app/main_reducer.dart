import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/config/reducer.dart';
import 'package:bible_game/app/confirm_quit_dialog/reducer.dart';
import 'package:bible_game/app/db/reducer.dart';
import 'package:bible_game/app/error/reducer.dart';
import 'package:bible_game/app/explorer/reducer.dart';
import 'package:bible_game/app/game/reducer/reducer.dart';
import 'package:bible_game/app/game_editor/reducer/reducer.dart';
import 'package:bible_game/app/router/reducer.dart';
import 'package:bible_game/app/texts.dart';
import 'package:bible_game/app/theme/reducer.dart';
import 'package:bible_game/games/maze/redux/reducer.dart';
import 'package:bible_game/games/words_in_word/reducer/reducer.dart';

AppState mainReducer(AppState state, action) {
  return AppState(
    dba: state.dba,
    sfx: state.sfx,
    texts: AppTexts(),
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
    maze: mazeReducer(state.maze, action),
    quitSingleGameDialog: quitSingleGameDialogReducer(state.quitSingleGameDialog, action),
  );
}
