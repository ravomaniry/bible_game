import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/inventory/actions/bonus.dart' as bonusActions;
import 'package:bible_game/app/inventory/reducer/state.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';

class InGameBonusViewModel {
  final Function(Bonus) use;
  final InventoryState inventory;
  final AppColorTheme theme;

  InGameBonusViewModel({
    @required this.use,
    @required this.inventory,
    @required this.theme,
  });

  static InGameBonusViewModel converter(Store<AppState> store) {
    return InGameBonusViewModel(
      theme: store.state.theme,
      inventory: store.state.game.inventory,
      use: (Bonus bonus) => store.dispatch(bonusActions.useBonus(bonus, true)),
    );
  }
}
