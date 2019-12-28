import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/quit_single_game_dialog/actions.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class QuitSingleGameViewModel {
  final bool isOpen;
  final Function() confirmHandler;
  final Function() cancelHandler;

  QuitSingleGameViewModel({
    @required this.isOpen,
    @required this.cancelHandler,
    @required this.confirmHandler,
  });

  static QuitSingleGameViewModel converter(Store<AppState> store) {
    return QuitSingleGameViewModel(
      isOpen: store.state.quitSingleGameDialog,
      cancelHandler: () => store.dispatch(CloseQuitSingleGameDialog()),
      confirmHandler: () {
        store.dispatch(goToHome());
        store.dispatch(CloseQuitSingleGameDialog());
      },
    );
  }
}
