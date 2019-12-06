import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/redux/inventory/actions.dart';
import 'package:bible_game/redux/inventory/state.dart';

InventoryState inventoryReducer(InventoryState state, action) {
  if (action is UpdateInventory) {
    return action.payload;
  } else if (action is OpenInventoryDialog) {
    return state.copyWith(isOpen: true, isInGame: action.isInGame);
  } else if (action is CloseInventoryDialog) {
    return state.copyWith(isOpen: false);
  } else if (action is BuyBonus) {
    return _buyBonusReducerUtil(state, action.payload);
  } else if (action is InvalidateCombo) {
    return state.copyWith(combo: 1);
  }
  return state;
}

InventoryState _buyBonusReducerUtil(InventoryState state, Bonus bonus) {
  if (state.money >= bonus.price) {
    state = state.copyWith(money: state.money - bonus.price);
    if (bonus is RevealCharBonus1) {
      return state.copyWith(revealCharBonus1: state.revealCharBonus1 + 1);
    } else if (bonus is RevealCharBonus2) {
      return state.copyWith(revealCharBonus2: state.revealCharBonus2 + 1);
    } else if (bonus is RevealCharBonus5) {
      return state.copyWith(revealCharBonus5: state.revealCharBonus5 + 1);
    } else if (bonus is RevealCharBonus10) {
      return state.copyWith(revealCharBonus10: state.revealCharBonus10 + 1);
    } else if (bonus is SolveOneTurn) {
      return state.copyWith(solveOneTurnBonus: state.solveOneTurnBonus + 1);
    }
  }
  return state;
}
