import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/game/actions/lists_handler.dart';
import 'package:bible_game/app/inventory/reducer/state.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/sfx/actions.dart';
import 'package:redux_thunk/redux_thunk.dart';

class OpenInventoryDialog {
  final bool isInGame;

  OpenInventoryDialog(this.isInGame);
}

class CloseInventoryDialog {}

ThunkAction<AppState> inventoryNextHandler() {
  return (store) {
    store.dispatch(CloseInventoryDialog());
    store.dispatch(saveActiveGame());
    store.dispatch(playGreetingSfx());
  };
}

class UpdateInventory {
  final InventoryState payload;

  UpdateInventory(this.payload);
}

class InvalidateCombo {}

class BuyBonus {
  final Bonus payload;

  BuyBonus(this.payload);
}

ThunkAction<AppState> buyBonus(Bonus bonus) {
  return (store) {
    final prevMoney = store.state.game.inventory.money;
    store.dispatch(BuyBonus(bonus));
    if (prevMoney != store.state.game.inventory.money) {
      store.state.sfx.playBonus();
    }
  };
}

class DecrementBonus {
  final Bonus payload;

  DecrementBonus(this.payload);
}

ThunkAction<AppState> incrementMoney(int delta) {
  return (store) async {
    final state = store.state.game.inventory;
    final nextMoney = (state.money + delta * state.combo).round();
    double nextCombo = state.combo;
    final deltaCombo = delta / 10;
    if (nextCombo > 1 || deltaCombo >= 0.5) {
      nextCombo += deltaCombo;
    }
    store.dispatch(UpdateInventory(
      store.state.game.inventory.copyWith(
        money: nextMoney,
        combo: nextCombo,
      ),
    ));
    if (state.combo == 1 && nextCombo > 1) {
      await Future.delayed(Duration(seconds: 20));
      store.dispatch(InvalidateCombo());
    }
  };
}
