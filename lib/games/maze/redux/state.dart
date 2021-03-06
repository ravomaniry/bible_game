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
  final List<int> wordsToReveal;
  final List<int> wordsToConfirm;
  final List<Coordinate> confirmed;
  final List<Coordinate> hints;

  MazeState({
    @required this.board,
    @required this.words,
    @required this.nextId,
    @required this.backgrounds,
    this.revealed = const [],
    this.paths = const [],
    this.newlyRevealed = const [],
    this.wordsToReveal = const [],
    this.confirmed = const [],
    this.wordsToConfirm = const [],
    this.hints = const [],
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
    final List<int> wordsToConfirm,
    final List<Coordinate> confirmed,
    final List<Coordinate> hints,
  }) {
    return MazeState(
      board: board ?? this.board,
      words: words ?? this.words,
      nextId: nextId ?? this.nextId,
      backgrounds: backgrounds ?? this.backgrounds,
      revealed: revealed ?? this.revealed,
      paths: paths ?? this.paths,
      newlyRevealed: newlyRevealed ?? this.newlyRevealed,
      wordsToReveal: wordsToFind ?? this.wordsToReveal,
      wordsToConfirm: wordsToConfirm ?? this.wordsToConfirm,
      confirmed: confirmed ?? this.confirmed,
      hints: hints ?? this.hints,
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
