import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/explorer/actions.dart' as ExplorerActions;
import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/app/game/actions/lists_handler.dart';
import 'package:bible_game/app/game/actions/next_verse.dart';
import 'package:bible_game/app/game/reducer/state.dart';
import 'package:bible_game/app/game_editor/actions/actions.dart' as EditorActions;
import 'package:bible_game/app/help/actions/init.dart' as HelpAction;
import 'package:bible_game/app/inventory/actions/actions.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/models/game.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class GameViewModel {
  final bool isReady;
  final GameState state;
  final Function() toggleDialog;
  final Function() goToExplorer;
  final Function() goToEditor;
  final Function() goToHelp;
  final Function() openInventory;
  final Function(GameModelWrapper) selectHandler;
  final Function() nextHandler;
  final Function() expandVersesHandler;
  final AppColorTheme theme;

  GameViewModel({
    @required this.isReady,
    @required this.state,
    @required this.toggleDialog,
    @required this.selectHandler,
    @required this.openInventory,
    @required this.goToExplorer,
    @required this.nextHandler,
    @required this.theme,
    @required this.goToEditor,
    @required this.goToHelp,
    @required this.expandVersesHandler,
  });

  static GameViewModel converter(Store<AppState> store) {
    return GameViewModel(
      state: store.state.game,
      theme: store.state.theme,
      isReady: store.state.dbState.isReady,
      toggleDialog: () => store.dispatch(ToggleGamesEditorDialog()),
      goToExplorer: () => store.dispatch(ExplorerActions.goToExplorer()),
      openInventory: () => store.dispatch(OpenInventoryDialog(false)),
      selectHandler: (GameModelWrapper game) => store.dispatch(selectGameHandler(game)),
      nextHandler: () => store.dispatch(saveGameAndLoadNextVerse()),
      goToEditor: () => store.dispatch(EditorActions.goToEditor()),
      expandVersesHandler: () => store.dispatch(expandVerses()),
      goToHelp: () => store.dispatch(HelpAction.goToHelp()),
    );
  }
}
