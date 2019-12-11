import 'dart:convert';

import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:flutter/cupertino.dart';

final _moneyJsonEntry = "money";
final _revealCharBonusJsonEntry = "rcb_";

int _getRevealCharBonusNum(int power, Map<String, int> bonuses) {
  return bonuses["$_revealCharBonusJsonEntry$power"];
}

class GameModelWrapper {
  final GameModel model;
  final InventoryState inventory;
  final int resolvedVersesCount;
  final int nextBook;
  final int nextChapter;
  final int nextVerse;

  GameModelWrapper({
    @required this.model,
    @required this.inventory,
    @required this.resolvedVersesCount,
    @required this.nextBook,
    @required this.nextChapter,
    @required this.nextVerse,
  });

  factory GameModelWrapper.fromModel(GameModel model) {
    final Map<String, int> bonuses = json.decode(model.bonuses);
    final int money = bonuses["$_moneyJsonEntry"] ?? 0;
    final int revealChar1 = _getRevealCharBonusNum(1, bonuses) ?? 0;
    final int revealChar2 = _getRevealCharBonusNum(2, bonuses) ?? 0;
    final int revealChar5 = _getRevealCharBonusNum(5, bonuses) ?? 0;
    final int revealChar10 = _getRevealCharBonusNum(10, bonuses) ?? 0;
    final inventory = InventoryState.emptyState().copyWith(
      money: money,
      revealCharBonus1: revealChar1,
      revealCharBonus2: revealChar2,
      revealCharBonus5: revealChar5,
      revealCharBonus10: revealChar10,
    );

    return GameModelWrapper(
      model: model,
      inventory: inventory,
      resolvedVersesCount: model.resolvedVersesCount,
      nextBook: model.nextBook,
      nextChapter: model.nextChapter,
      nextVerse: model.nextVerse,
    );
  }

  String get _bonusesStringHelper {
    final map = Map<String, int>();
    map["${_revealCharBonusJsonEntry}1"] = inventory.revealCharBonus1;
    map["${_revealCharBonusJsonEntry}2"] = inventory.revealCharBonus2;
    map["${_revealCharBonusJsonEntry}5"] = inventory.revealCharBonus5;
    map["${_revealCharBonusJsonEntry}10"] = inventory.revealCharBonus10;
    return json.encode(map);
  }

  GameModelWrapper copyWith({
    int resolvedVersesCount,
    int nextBook,
    int nextChapter,
    int nextVerse,
    InventoryState inventory,
  }) {
    return GameModelWrapper(
      model: this.model,
      resolvedVersesCount: resolvedVersesCount ?? this.resolvedVersesCount,
      nextBook: nextBook ?? this.nextBook,
      nextChapter: nextChapter ?? this.nextChapter,
      nextVerse: nextVerse ?? this.nextVerse,
      inventory: inventory ?? this.inventory,
    );
  }

  GameModel toModelHelper() {
    return GameModel(
      id: model.id,
      name: model.name,
      startBook: model.startBook,
      startChapter: model.startChapter,
      startVerse: model.startVerse,
      endBook: model.endBook,
      endChapter: model.endChapter,
      endVerse: model.endVerse,
      versesCount: model.versesCount,
      resolvedVersesCount: -resolvedVersesCount,
      nextBook: nextBook,
      nextChapter: nextChapter,
      nextVerse: nextVerse,
      money: inventory.money,
      bonuses: _bonusesStringHelper,
    );
  }
}
