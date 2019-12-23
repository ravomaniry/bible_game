import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/editor/state.dart';
import 'package:bible_game/redux/error/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/game/state.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:bible_game/redux/words_in_word/state.dart';
import 'package:bible_game/sfx/sfx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AppState {
  final Sfx sfx;
  final GameState game;
  final Routes route;
  final WordsInWordState wordsInWord;
  final bool quitSingleGameDialog;
  final DbAdapter dba;
  final bool dbIsReady;
  final ErrorState error;
  final AssetBundle assetBundle;
  final ExplorerState explorer;
  final EditorState editor;
  final ConfigState config;
  final AppColorTheme theme;

  AppState({
    this.route = Routes.home,
    this.wordsInWord,
    this.quitSingleGameDialog = false,
    this.dbIsReady = false,
    this.error,
    @required this.sfx,
    @required this.game,
    @required this.dba,
    @required this.assetBundle,
    @required this.explorer,
    @required this.config,
    @required this.theme,
    @required this.editor,
  });

  factory AppState.initialState(AssetBundle assetBundle) {
    return AppState(
      assetBundle: assetBundle,
      explorer: ExplorerState(),
      sfx: Sfx(),
      config: ConfigState.initialState(),
      theme: AppColorTheme(),
      editor: EditorState(),
      dba: DbAdapter(
        db: BibleGameModel(),
        bookModel: BookModel(),
        verseModel: VerseModel(),
        gameModel: GameModel(),
      ),
      game: GameState(
        verse: null,
        list: [],
        books: [],
        dialogIsOpen: false,
        activeId: null,
        inventory: InventoryState.emptyState(),
      ),
    );
  }
}
