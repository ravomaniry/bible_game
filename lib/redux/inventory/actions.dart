import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/models/thunk_container.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:redux/redux.dart';

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

class IncrementMoney extends ThunkContainer {
  final Word _revealedWord;

  IncrementMoney(this._revealedWord) {
    this.thunk = (Store<AppState> store) {
      final state = store.state.inventory;
      final nextMoney = state.money + _revealedWord.chars.length * state.combo;
      int nextCombo = 1;
      if (state.combo > 1) {
        nextCombo = state.combo + (_revealedWord.chars.length / 2).floor();
      } else {
        nextCombo = _revealedWord.chars.length;
      }
      store.dispatch(UpdateInventory(state.copyWith(money: nextMoney, combo: nextCombo)));
    };
  }
}
