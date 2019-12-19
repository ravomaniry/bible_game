import 'package:bible_game/models/game.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/game/actions.dart';
import 'package:bible_game/redux/game/lists_handler.dart';
import 'package:bible_game/redux/game/next_verse.dart';
import 'package:bible_game/redux/game/state.dart';
import 'package:bible_game/redux/inventory/actions.dart';
import 'package:bible_game/redux/themes/default_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';
import 'package:bible_game/redux/explorer/actions.dart' as ExplorerActions;

class GameViewModel {
  final bool isReady;
  final GameState state;
  final Function() toggleDialog;
  final Function() goToExplorer;
  final Function() openInventory;
  final Function(GameModelWrapper) selectHandler;
  final Function() nextHandler;
  final DefaultTheme theme;

  GameViewModel({
    @required this.isReady,
    @required this.state,
    @required this.toggleDialog,
    @required this.selectHandler,
    @required this.openInventory,
    @required this.goToExplorer,
    @required this.nextHandler,
    @required this.theme,
  });

  static GameViewModel converter(Store<AppState> store) {
    return GameViewModel(
      state: store.state.game,
      theme: store.state.theme,
      isReady: store.state.dbIsReady,
      toggleDialog: () => store.dispatch(ToggleGamesEditorDialog()),
      goToExplorer: () => store.dispatch(ExplorerActions.goToExplorer),
      openInventory: () => store.dispatch(OpenInventoryDialog(false)),
      selectHandler: (GameModelWrapper game) => store.dispatch(SelectGame(game).thunk),
      nextHandler: () => store.dispatch(saveGameAndLoadNextVerse),
    );
  }
}
