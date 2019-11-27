import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/router/actions.dart' as action;
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class HomeViewModel {
  Function() goToCalculator;
  Function() goToWordsInWord;

  HomeViewModel({
    @required this.goToCalculator,
    @required this.goToWordsInWord,
  });

  static HomeViewModel converter(Store<AppState> store) {
    return HomeViewModel(
      goToCalculator: () => store.dispatch(action.goToCalculator),
      goToWordsInWord: () => store.dispatch(action.goToWordsInWord),
    );
  }
}
