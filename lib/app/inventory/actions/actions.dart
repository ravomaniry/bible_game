import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/game/actions/lists_handler.dart';
import 'package:bible_game/app/inventory/reducer/state.dart';
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

ThunkAction<AppState> incrementMoney(BibleVerse prevVerse, BibleVerse nextVerse) {
  return (store) {
    final state = store.state.game.inventory;
    final deltaMoney = _getDeltaMoney(prevVerse, nextVerse);
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

int _getDeltaMoney(BibleVerse prevVerse, BibleVerse nextVerse) {
  int deltaMoney = 0;
  for (var i = 0; i < prevVerse.words.length; i++) {
    if (nextVerse.words[i] != prevVerse.words[i]) {
      deltaMoney += nextVerse.words[i].chars.where((c) => !c.resolved).length;
    }
  }
  return deltaMoney;
}
