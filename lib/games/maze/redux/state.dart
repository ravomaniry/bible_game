import 'dart:ui' as ui;

import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/widgets.dart';

class MazeState {
  final Board board;
  final List<Word> words;
  final int nextId;
  final Map<String, ui.Image> backgrounds;
  final List<List<bool>> revealed;
  final List<List<Coordinate>> paths;
  final List<Coordinate> newlyRevealed;
  final List<int> wordsToFind;
  final List<Coordinate> confirmed;

  MazeState({
    @required this.board,
    @required this.words,
    @required this.nextId,
    @required this.backgrounds,
    this.revealed = const [],
    this.paths = const [],
    this.newlyRevealed = const [],
    this.wordsToFind = const [],
    this.confirmed = const [],
  });

  factory MazeState.emptyState() {
    return MazeState(
      board: null,
      words: [],
      nextId: 0,
      backgrounds: null,
    );
  }

  MazeState copyWith({
    final Board board,
    final List<Word> words,
    final int nextId,
    final Map<String, ui.Image> backgrounds,
    final List<List<bool>> revealed,
    final List<List<Coordinate>> paths,
    final List<Coordinate> newlyRevealed,
    final List<int> wordsToFind,
    final List<Coordinate> confirmed,
  }) {
    return MazeState(
      board: board ?? this.board,
      words: words ?? this.words,
      nextId: nextId ?? this.nextId,
      backgrounds: backgrounds ?? this.backgrounds,
      revealed: revealed ?? this.revealed,
      paths: paths ?? this.paths,
      newlyRevealed: newlyRevealed ?? this.newlyRevealed,
      wordsToFind: wordsToFind ?? this.wordsToFind,
      confirmed: confirmed ?? this.confirmed,
    );
  }

  MazeState reset(int id) {
    return MazeState(
      board: null,
      words: [],
      nextId: id,
      backgrounds: this.backgrounds,
    );
  }
}
