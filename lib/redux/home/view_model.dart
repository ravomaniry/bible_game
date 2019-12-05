import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/explorer/actions.dart' as ExplorerActions;
import 'package:bible_game/redux/inventory/actions.dart';
import 'package:bible_game/redux/router/actions.dart' as action;
import 'package:bible_game/redux/words_in_word/actions.dart' as wordsInWordActions;
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class HomeViewModel {
  final bool isReady;
  final Function() goToCalculator;
  final Function() goToWordsInWord;
  final Function() goToExplorer;
  final Function() openInventory;

  HomeViewModel({
    @required this.isReady,
    @required this.goToCalculator,
    @required this.goToWordsInWord,
    @required this.goToExplorer,
    @required this.openInventory,
  });

  static HomeViewModel converter(Store<AppState> store) {
    return HomeViewModel(
      isReady: store.state.dbIsReady,
      goToCalculator: () => store.dispatch(action.goToCalculator),
      goToWordsInWord: () => store.dispatch(wordsInWordActions.goToWordsInWord),
      goToExplorer: () => store.dispatch(ExplorerActions.goToExplorer),
      openInventory: () => store.dispatch(OpenInventoryDialog(false)),
    );
  }
}
