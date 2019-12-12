import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/games/actions.dart';
import 'package:bible_game/redux/games/state.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class GamesListViewModel {
  final GamesState state;
  final Function() toggleDialog;

  GamesListViewModel({
    @required this.state,
    @required this.toggleDialog,
  });

  static GamesListViewModel converter(Store<AppState> store) {
    return GamesListViewModel(
      state: store.state.games,
      toggleDialog: () => store.dispatch(ToggleGamesEditorDialog()),
    );
  }
}
