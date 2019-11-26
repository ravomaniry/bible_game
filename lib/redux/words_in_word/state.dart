import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/foundation.dart';

class WordsInWordState {
  final BibleVerse verse;
  final List<List<Cell>> cells;
  final List<Char> chars;
  final List<Char> selected;

  WordsInWordState({
    @required this.verse,
    @required this.cells,
    @required this.chars,
    @required this.selected,
  });

  factory WordsInWordState.emptyState() {
    return WordsInWordState(
      verse: BibleVerse(book: "Matio", chapter: 1, verse: 1, words: []),
      selected: [],
      chars: [],
      cells: [],
    );
  }

  WordsInWordState copyWith({
    BibleVerse verse,
    List<List<Cell>> cells,
    List<Char> chars,
    List<Char> selected,
  }) {
    return WordsInWordState(
      verse: verse ?? this.verse,
      cells: cells ?? this.cells,
      chars: chars ?? this.chars,
      selected: selected ?? this.selected,
    );
  }
}
