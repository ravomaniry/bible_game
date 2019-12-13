import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/redux/inventory/state.dart';

InventoryState buyBonusReducerUtil(InventoryState state, Bonus bonus) {
  return _changeBonusNumber(state, bonus, 1);
}

InventoryState decrementBonusReducerUtil(InventoryState state, Bonus bonus) {
  return _changeBonusNumber(state, bonus, -1);
}

InventoryState _changeBonusNumber(InventoryState state, Bonus bonus, int delta) {
  final canChange = state.money >= bonus.price * delta;
  if (canChange) {
    if (delta > 0) {
      state = state.copyWith(money: state.money - bonus.price * delta);
    }
    if (bonus is RevealCharBonus) {
      switch (bonus.power) {
        case 1:
          return state.copyWith(revealCharBonus1: state.revealCharBonus1 + delta);
        case 2:
          return state.copyWith(revealCharBonus2: state.revealCharBonus2 + delta);
        case 5:
          return state.copyWith(revealCharBonus5: state.revealCharBonus5 + delta);
        case 10:
          return state.copyWith(revealCharBonus10: state.revealCharBonus10 + delta);
      }
    } else if (bonus is SolveOneTurn) {
      return state.copyWith(solveOneTurnBonus: state.solveOneTurnBonus + delta);
    }
  }
  return state;
}
