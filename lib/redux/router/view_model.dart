import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class RouterViewModel {
  final Routes route;
  final bool gameIsResolved;
  final bool activeGameIsCompleted;

  RouterViewModel({
    @required this.route,
    @required this.gameIsResolved,
    @required this.activeGameIsCompleted,
  });

  static RouterViewModel converter(Store<AppState> store) {
    return RouterViewModel(
      route: store.state.route,
      gameIsResolved: store.state.game.isResolved,
      activeGameIsCompleted: store.state.game.activeGameIsCompleted,
    );
  }
}
