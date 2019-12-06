import 'package:flutter/foundation.dart';

class InventoryState {
  final bool isOpen;
  final bool isInGame;
  final int money;
  final int combo;
  final int revealCharBonus1;
  final int revealCharBonus2;
  final int revealCharBonus5;
  final int revealCharBonus10;
  final int solveOneTurnBonus;

  InventoryState({
    @required this.isOpen,
    @required this.isInGame,
    @required this.money,
    @required this.combo,
    @required this.revealCharBonus1,
    @required this.revealCharBonus2,
    @required this.revealCharBonus5,
    @required this.revealCharBonus10,
    @required this.solveOneTurnBonus,
  });

  factory InventoryState.emptyState() {
    return InventoryState(
      isOpen: false,
      isInGame: false,
      money: 100,
      combo: 1,
      revealCharBonus1: 0,
      revealCharBonus2: 0,
      revealCharBonus5: 0,
      revealCharBonus10: 0,
      solveOneTurnBonus: 0,
    );
  }

  InventoryState copyWith({
    bool isOpen,
    bool isInGame,
    int money,
    int combo,
    int revealCharBonus1,
    int revealCharBonus2,
    int revealCharBonus5,
    int revealCharBonus10,
    int solveOneTurnBonus,
  }) {
    return InventoryState(
      isOpen: isOpen ?? this.isOpen,
      isInGame: isInGame ?? this.isInGame,
      money: money ?? this.money,
      combo: combo ?? this.combo,
      revealCharBonus1: revealCharBonus1 ?? this.revealCharBonus1,
      revealCharBonus2: revealCharBonus2 ?? this.revealCharBonus2,
      revealCharBonus5: revealCharBonus5 ?? this.revealCharBonus5,
      revealCharBonus10: revealCharBonus10 ?? this.revealCharBonus10,
      solveOneTurnBonus: solveOneTurnBonus ?? this.solveOneTurnBonus,
    );
  }
}
