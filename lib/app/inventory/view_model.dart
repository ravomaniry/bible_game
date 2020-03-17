import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/inventory/actions/actions.dart' as actions;
import 'package:bible_game/app/inventory/reducer/state.dart';
import 'package:bible_game/app/texts.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class InventoryViewModel {
  final InventoryState state;
  final Function(Bonus) buyBonus;
  final Function() closeDialog;
  final AppColorTheme theme;
  final AppTexts texts;

  InventoryViewModel({
    @required this.state,
    @required this.buyBonus,
    @required this.closeDialog,
    @required this.theme,
    @required this.texts,
  });

  static InventoryViewModel converter(Store<AppState> store) {
    return InventoryViewModel(
      theme: store.state.theme,
      texts: store.state.texts,
      state: store.state.game.inventory,
      buyBonus: (Bonus bonus) => store.dispatch(actions.buyBonus(bonus)),
      closeDialog: () => store.dispatch(actions.inventoryNextHandler()),
    );
  }
}
