import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/game/actions.dart';
import 'package:bible_game/redux/game/state.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class EditorViewModel {
  final GameState state;
  final Function() toggleDialog;
  final AppColorTheme theme;
  final Function(int value) startBookChangeHandler;

  EditorViewModel({
    @required this.state,
    @required this.toggleDialog,
    @required this.theme,
    @required this.startBookChangeHandler,
  });

  static EditorViewModel converter(Store<AppState> store) {
    return EditorViewModel(
      state: store.state.game,
      theme: store.state.theme,
      toggleDialog: () => store.dispatch(ToggleGamesEditorDialog()),
      startBookChangeHandler: (int value) => store.dispatch(UpdateEditorFormData(
        store.state.game.formData.copyWith(startBook: value),
      )),
    );
  }
}
