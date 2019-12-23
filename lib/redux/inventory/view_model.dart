import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/inventory/actions.dart' as actions;
import 'package:bible_game/redux/inventory/state.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class InventoryViewModel {
  final InventoryState state;
  final Function(Bonus) buyBonus;
  final Function() closeDialog;
  final AppColorTheme theme;

  InventoryViewModel({
    @required this.state,
    @required this.buyBonus,
    @required this.closeDialog,
    @required this.theme,
  });

  static InventoryViewModel converter(Store<AppState> store) {
    return InventoryViewModel(
      theme: store.state.theme,
      state: store.state.game.inventory,
      buyBonus: (Bonus bonus) => store.dispatch(actions.buyBonus(bonus)),
      closeDialog: () => store.dispatch(actions.inventoryNextHandler),
    );
  }
}
