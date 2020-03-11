import 'dart:ui' as ui;

import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/widgets.dart';

class MazeState {
  final Board board;
  final List<Word> wordsToFind;
  final int nextId;
  final Map<String, ui.Image> backgrounds;
  final List<List<bool>> revealed;
  final List<List<Coordinate>> paths;
  final List<Coordinate> newlyRevealed;

  MazeState({
    @required this.board,
    @required this.wordsToFind,
    @required this.nextId,
    @required this.backgrounds,
    this.revealed = const [],
    this.paths = const [],
    this.newlyRevealed = const [],
  });

  factory MazeState.emptyState() {
    return MazeState(
      board: null,
      wordsToFind: [],
      nextId: 0,
      backgrounds: null,
    );
  }

  MazeState copyWith({
    final Board board,
    final List<Word> wordsToFind,
    final int nextId,
    final Map<String, ui.Image> backgrounds,
    final List<List<bool>> revealed,
    final List<List<Coordinate>> paths,
    final List<Coordinate> newlyRevealed,
  }) {
    return MazeState(
      board: board ?? this.board,
      wordsToFind: wordsToFind ?? this.wordsToFind,
      nextId: nextId ?? this.nextId,
      backgrounds: backgrounds ?? this.backgrounds,
      revealed: revealed ?? this.revealed,
      paths: paths ?? this.paths,
      newlyRevealed: newlyRevealed ?? this.newlyRevealed,
    );
  }

  MazeState reset(int id) {
    return MazeState(
      board: null,
      wordsToFind: [],
      revealed: [],
      nextId: id,
      backgrounds: this.backgrounds,
    );
  }
}
