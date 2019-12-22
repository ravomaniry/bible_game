import 'package:bible_game/db/model.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/game.dart';
import 'package:bible_game/redux/game/editor_form_data.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:flutter/foundation.dart';

class GameState {
  final BibleVerse verse;
  final List<BookModel> books;
  final int activeId;
  final bool dialogIsOpen;
  final List<GameModelWrapper> list;
  final int startBook;
  final int startChapter;
  final int startVerse;
  final int endBook;
  final int endChapter;
  final int endVerse;
  final bool isResolved;
  final bool activeGameIsCompleted;
  final InventoryState inventory;
  final EditorFormData formData;

  GameState({
    @required this.books,
    @required this.verse,
    @required this.activeId,
    @required this.dialogIsOpen,
    @required this.list,
    @required this.inventory,
    @required this.formData,
    this.startBook = -1,
    this.startChapter = -1,
    this.startVerse = -1,
    this.endBook = -1,
    this.endChapter = -1,
    this.endVerse = -1,
    this.isResolved = false,
    this.activeGameIsCompleted = false,
  });

  factory GameState.emptyState() => GameState(
        verse: null,
        books: [],
        activeId: null,
        dialogIsOpen: false,
        list: [],
        inventory: InventoryState.emptyState(),
        formData: EditorFormData(),
      );

  GameState copyWith({
    final bool isResolved,
    final BibleVerse verse,
    final List<BookModel> books,
    final InventoryState inventory,
    final int activeId,
    final bool dialogIsOpen,
    final List<GameModelWrapper> list,
    final EditorFormData formData,
    final int startBook,
    final int startChapter,
    final int startVerse,
    final int endBook,
    final int endChapter,
    final int endVerse,
    final bool activeGameIsCompleted,
  }) {
    return GameState(
      isResolved: isResolved ?? this.isResolved,
      verse: verse ?? this.verse,
      books: books ?? this.books,
      inventory: inventory ?? this.inventory,
      activeId: activeId ?? this.activeId,
      dialogIsOpen: dialogIsOpen ?? this.dialogIsOpen,
      list: list ?? this.list,
      formData: formData ?? this.formData,
      startBook: startBook ?? this.startBook,
      startChapter: startChapter ?? this.startChapter,
      startVerse: startVerse ?? this.startVerse,
      endBook: endBook ?? this.endBook,
      endChapter: endChapter ?? this.endChapter,
      endVerse: endVerse ?? this.endVerse,
      activeGameIsCompleted: activeGameIsCompleted ?? this.activeGameIsCompleted,
    );
  }

  GameState copyWithListItem(GameModelWrapper item, int index) {
    final list = List<GameModelWrapper>.from(this.list);
    return copyWith(list: list);
  }

  GameState resetForm() {
    return copyWith(
      startBook: -1,
      startChapter: -1,
      startVerse: -1,
      endBook: -1,
      endChapter: -1,
      endVerse: -1,
    );
  }

  GameState resolvedState() {
    return copyWith(isResolved: true);
  }
}
