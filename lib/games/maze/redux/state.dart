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
  final List<Coordinate> revealed;

  MazeState({
    @required this.board,
    @required this.wordsToFind,
    @required this.nextId,
    @required this.backgrounds,
    this.revealed = const [],
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
    final List<Coordinate> revealed,
  }) {
    return MazeState(
      board: board ?? this.board,
      wordsToFind: wordsToFind ?? this.wordsToFind,
      nextId: nextId ?? this.nextId,
      backgrounds: backgrounds ?? this.backgrounds,
      revealed: revealed ?? this.revealed,
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
