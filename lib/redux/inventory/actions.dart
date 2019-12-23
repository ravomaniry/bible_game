import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/models/thunk_container.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class OpenInventoryDialog {
  final bool isInGame;

  OpenInventoryDialog(this.isInGame);
}

class CloseInventoryDialog {}

final closeInventoryDialog = CloseInventoryDialog();

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
  return (Store<AppState> store) {
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

class IncrementMoney extends ThunkContainer {
  final BibleVerse _prev;
  final BibleVerse _next;

  IncrementMoney(this._prev, this._next) {
    this.thunk = (Store<AppState> store) {
      final state = store.state.game.inventory;
      final deltaMoney = _getDeltaMoney();
      final nextMoney = (state.money + deltaMoney * state.combo).round();
      double nextCombo = state.combo;
      final deltaCombo = deltaMoney / 10;
      if (nextCombo > 1 || deltaCombo >= 0.5) {
        nextCombo += deltaCombo;
      }
      store.dispatch(UpdateInventory(
        store.state.game.inventory.copyWith(
          money: nextMoney,
          combo: nextCombo,
        ),
      ));
    };
  }

  int _getDeltaMoney() {
    int deltaMoney = 0;
    for (var i = 0; i < _prev.words.length; i++) {
      if (_next.words[i] != _prev.words[i]) {
        deltaMoney += _next.words[i].chars.where((c) => !c.resolved).length;
      }
    }
    return deltaMoney;
  }
}
