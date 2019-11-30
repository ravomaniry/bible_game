import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/foundation.dart';

class WordsInWordState {
  final BibleVerse verse;
  final List<Word> resolvedWords;
  final List<Word> wordsToFind;
  final List<List<Cell>> cells;
  final List<Char> slots;
  final List<Char> proposition;

  WordsInWordState({
    @required this.verse,
    @required this.cells,
    @required this.slots,
    @required this.proposition,
    @required this.wordsToFind,
    this.resolvedWords = const [],
  });

  factory WordsInWordState.emptyState() {
    return WordsInWordState(
      verse: BibleVerse(book: "Matio", bookId: 1, chapter: 1, verse: 1, words: []),
      wordsToFind: [],
      resolvedWords: [],
      proposition: [],
      slots: [],
      cells: [],
    );
  }

  WordsInWordState copyWith({
    BibleVerse verse,
    List<List<Cell>> cells,
    List<Char> slots,
    List<Char> selected,
    List<Word> wordsToFind,
    List<Word> resolvedWords,
  }) {
    return WordsInWordState(
      verse: verse ?? this.verse,
      cells: cells ?? this.cells,
      slots: slots ?? this.slots,
      proposition: selected ?? this.proposition,
      wordsToFind: wordsToFind ?? this.wordsToFind,
      resolvedWords: resolvedWords ?? this.resolvedWords,
    );
  }
}
