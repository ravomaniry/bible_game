import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class RouterViewModel {
  final Routes route;
  final bool calculatorIsReady;
  final bool wordsInWordIsReady;
  final Function(Routes) goTo;

  RouterViewModel({
    @required this.route,
    @required this.calculatorIsReady,
    @required this.wordsInWordIsReady,
    @required this.goTo,
  });

  static RouterViewModel converter(Store<AppState> store) {
    return RouterViewModel(
      route: store.state.route,
      goTo: (Routes route) => store.dispatch(GoToAction(route)),
      calculatorIsReady: store.state.calculator != null,
      wordsInWordIsReady: store.state.wordsInWord != null,
    );
  }
}
