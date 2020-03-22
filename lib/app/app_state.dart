import 'package:bible_game/app/config/state.dart';
import 'package:bible_game/app/db/state.dart';
import 'package:bible_game/app/error/state.dart';
import 'package:bible_game/app/explorer/state.dart';
import 'package:bible_game/app/game/reducer/state.dart';
import 'package:bible_game/app/game_editor/reducer/state.dart';
import 'package:bible_game/app/help/state.dart';
import 'package:bible_game/app/inventory/reducer/state.dart';
import 'package:bible_game/app/router/routes.dart';
import 'package:bible_game/app/texts.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/games/maze/redux/state.dart';
import 'package:bible_game/games/words_in_word/reducer/state.dart';
import 'package:bible_game/sfx/sfx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AppState {
  final Sfx sfx;
  final GameState game;
  final Routes route;
  final WordsInWordState wordsInWord;
  final MazeState maze;
  final bool quitSingleGameDialog;
  final DbAdapter dba;
  final DbState dbState;

  final ErrorState error;
  final AssetBundle assetBundle;
  final ExplorerState explorer;
  final EditorState editor;
  final ConfigState config;
  final AppColorTheme theme;
  final AppTexts texts;
  final HelpState help;

  AppState({
    this.route = Routes.home,
    this.wordsInWord,
    this.quitSingleGameDialog = false,
    this.dbState = const DbState(),
    this.error,
    this.maze,
    this.help,
    @required this.sfx,
    @required this.game,
    @required this.dba,
    @required this.assetBundle,
    @required this.explorer,
    @required this.config,
    @required this.theme,
    @required this.editor,
    @required this.texts,
  });

  factory AppState.initialState(AssetBundle assetBundle) {
    return AppState(
      assetBundle: assetBundle,
      explorer: ExplorerState(),
      sfx: Sfx(),
      config: ConfigState.initialState(),
      theme: AppColorTheme(),
      editor: EditorState(),
      maze: MazeState.emptyState(),
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
      texts: AppTexts(),
    );
  }
}
