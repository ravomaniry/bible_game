import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/words_in_word/Char.dart';
import 'package:flutter/foundation.dart';

class WordsInWordState {
  final BibleVerse verse;
  final List<List<Cell>> cells;
  final List<WordsInWordChar> chars;
  final List<WordsInWordChar> selected;

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
    List<WordsInWordChar> chars,
    List<WordsInWordChar> selected,
  }) {
    return WordsInWordState(
      verse: verse ?? this.verse,
      cells: cells ?? this.cells,
      chars: chars ?? this.chars,
      selected: selected ?? this.selected,
    );
  }
}
