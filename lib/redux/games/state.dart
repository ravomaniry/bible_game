import 'package:bible_game/db/model.dart';
import 'package:bible_game/models/game.dart';
import 'package:flutter/foundation.dart';

class GamesListState {
  final List<BookModel> books;
  final int activeIndex;
  final bool dialogIsOpen;
  final List<GameModelWrapper> list;
  final int startBook;
  final int startChapter;
  final int startVerse;
  final int endBook;
  final int endChapter;
  final int endVerse;

  GamesListState({
    @required this.books,
    @required this.activeIndex,
    @required this.dialogIsOpen,
    @required this.list,
    this.startBook = -1,
    this.startChapter = -1,
    this.startVerse = -1,
    this.endBook = -1,
    this.endChapter = -1,
    this.endVerse = -1,
  });

  factory GamesListState.emptyState() => GamesListState(
        books: [],
        activeIndex: null,
        dialogIsOpen: false,
        list: [],
      );

  GamesListState copyWith({
    final List<BookModel> books,
    final int activeIndex,
    final bool dialogIsOpen,
    final List<GameModelWrapper> list,
    final int startBook,
    final int startChapter,
    final int startVerse,
    final int endBook,
    final int endChapter,
    final int endVerse,
  }) {
    return GamesListState(
      books: books ?? this.books,
      activeIndex: activeIndex ?? this.activeIndex,
      dialogIsOpen: dialogIsOpen ?? this.dialogIsOpen,
      list: list ?? this.list,
      startBook: startBook ?? this.startBook,
      startChapter: startChapter ?? this.startChapter,
      startVerse: startVerse ?? this.startVerse,
      endBook: endBook ?? this.endBook,
      endChapter: endChapter ?? this.endChapter,
      endVerse: endVerse ?? this.endVerse,
    );
  }

  GamesListState copyWithListItem(GameModelWrapper item, int index) {
    final list = List<GameModelWrapper>.from(this.list);
    return copyWith(list: list);
  }

  GamesListState resetForm() {
    return copyWith(
      startBook: -1,
      startChapter: -1,
      startVerse: -1,
      endBook: -1,
      endChapter: -1,
      endVerse: -1,
    );
  }
}
