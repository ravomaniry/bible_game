import 'package:bible_game/games/words_in_word/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/foundation.dart';

enum PropositionAnimations {
  success,
  failure,
  none,
}

class WordsInWordState {
  final List<Word> resolvedWords;
  final List<Word> wordsToFind;
  final List<List<Cell>> cells;
  final List<Char> slots;
  final List<Char> slotsBackup;
  final List<Char> proposition;
  final List<List<int>> slotsDisplayIndexes;
  final PropositionAnimations propositionAnimation;

  WordsInWordState({
    @required this.cells,
    @required this.slots,
    @required this.slotsBackup,
    @required this.proposition,
    @required this.wordsToFind,
    this.resolvedWords = const [],
    this.slotsDisplayIndexes = const [],
    this.propositionAnimation = PropositionAnimations.none,
  });

  factory WordsInWordState.emptyState() {
    return WordsInWordState(
      wordsToFind: [],
      resolvedWords: [],
      proposition: [],
      slots: [],
      cells: [],
      slotsBackup: [],
    );
  }

  WordsInWordState copyWith({
    List<List<Cell>> cells,
    List<Char> slots,
    List<Char> slotsBackup,
    List<Char> proposition,
    List<Word> wordsToFind,
    List<Word> resolvedWords,
    List<List<int>> slotsDisplayIndexes,
    final PropositionAnimations propositionAnimation,
  }) {
    return WordsInWordState(
      cells: cells ?? this.cells,
      slots: slots ?? this.slots,
      slotsBackup: slotsBackup ?? this.slotsBackup,
      proposition: proposition ?? this.proposition,
      wordsToFind: wordsToFind ?? this.wordsToFind,
      resolvedWords: resolvedWords ?? this.resolvedWords,
      slotsDisplayIndexes: slotsDisplayIndexes ?? this.slotsDisplayIndexes,
      propositionAnimation: propositionAnimation ?? this.propositionAnimation,
    );
  }
}
