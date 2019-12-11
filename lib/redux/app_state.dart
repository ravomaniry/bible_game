import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/calculator/state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/error/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/games/state.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/words_in_word/state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AppState {
  final Routes route;
  final GamesListState games;
  final CalculatorState calculator;
  final WordsInWordState wordsInWord;
  final bool quitSingleGameDialog;
  final InventoryState inventory;
  final DbAdapter dba;
  final bool dbIsReady;
  final ErrorState error;
  final AssetBundle assetBundle;
  final ExplorerState explorer;
  final ConfigState config;

  AppState({
    this.route = Routes.home,
    this.calculator,
    this.wordsInWord,
    this.quitSingleGameDialog = false,
    this.dbIsReady = false,
    this.error,
    @required this.games,
    @required this.dba,
    @required this.assetBundle,
    @required this.explorer,
    @required this.config,
    @required this.inventory,
  });

  factory AppState.initialState(AssetBundle assetBundle) {
    return AppState(
      assetBundle: assetBundle,
      explorer: ExplorerState(),
      config: ConfigState.initialState(),
      inventory: InventoryState.emptyState(),
      dba: DbAdapter(
        db: BibleGameModel(),
        bookModel: BookModel(),
        verseModel: VerseModel(),
        gameModel: GameModel(),
      ),
      games: GamesListState(
        list: [],
        dialogIsOpen: false,
        activeIndex: null,
      ),
    );
  }
}
