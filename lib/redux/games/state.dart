import 'package:bible_game/models/game.dart';
import 'package:flutter/foundation.dart';

class GamesListState {
  final int activeIndex;
  final bool dialogIsOpen;
  final List<GameModelWrapper> list;

  GamesListState({
    @required this.activeIndex,
    @required this.dialogIsOpen,
    @required this.list,
  });

  factory GamesListState.emptyState() => GamesListState(
        activeIndex: null,
        dialogIsOpen: false,
        list: [],
      );

  GamesListState copyWith({
    int activeIndex,
    bool dialogIsOpen,
    List<GameModelWrapper> list,
  }) {
    return GamesListState(
      activeIndex: activeIndex ?? this.activeIndex,
      dialogIsOpen: dialogIsOpen ?? this.dialogIsOpen,
      list: list ?? this.list,
    );
  }

  GamesListState copyWithListItem(GameModelWrapper item, int index) {
    final list = List<GameModelWrapper>.from(this.list);
    return copyWith(list: list);
  }
}
