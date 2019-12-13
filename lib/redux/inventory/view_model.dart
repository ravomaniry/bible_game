import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/game/lists_handler.dart';
import 'package:bible_game/redux/inventory/actions.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class InventoryViewModel {
  final InventoryState state;
  final Function(Bonus) buyBonus;
  final Function() closeDialog;

  InventoryViewModel({
    @required this.state,
    @required this.buyBonus,
    @required this.closeDialog,
  });

  static InventoryViewModel converter(Store<AppState> store) {
    return InventoryViewModel(
      state: store.state.game.inventory,
      buyBonus: (Bonus bonus) => store.dispatch(BuyBonus(bonus)),
      closeDialog: () {
        store.dispatch(closeInventoryDialog);
        store.dispatch(saveActiveGame);
      },
    );
  }
}
