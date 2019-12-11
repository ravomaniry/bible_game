import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/calculator/reducer.dart';
import 'package:bible_game/redux/config/reducer.dart';
import 'package:bible_game/redux/db/reducer.dart';
import 'package:bible_game/redux/error/reducer.dart';
import 'package:bible_game/redux/explorer/reducer.dart';
import 'package:bible_game/redux/games/reducer.dart';
import 'package:bible_game/redux/inventory/reducer.dart';
import 'package:bible_game/redux/quit_single_game_dialog/reducer.dart';
import 'package:bible_game/redux/router/reducer.dart';
import 'package:bible_game/redux/words_in_word/reducer.dart';

AppState mainReducer(AppState state, action) {
  return AppState(
    dba: state.dba,
    assetBundle: state.assetBundle,
    config: configReducer(state.config, action),
    error: errorReducer(state.error, action),
    route: routerReducer(state.route, action),
    dbIsReady: dbReducer(state.dbIsReady, action),
    games: gamesListStateReducer(state.games, action),
    explorer: explorerReducer(state.explorer, action),
    calculator: calculatorReducer(state.calculator, action),
    wordsInWord: wordsInWordReducer(state.wordsInWord, action),
    quitSingleGameDialog: quitSingleGameDialogReducer(state.quitSingleGameDialog, action),
    inventory: inventoryReducer(state.inventory, action),
  );
}
