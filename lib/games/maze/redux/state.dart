import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/widgets.dart';

class MazeState {
  final Board board;
  final List<Word> wordsToFind;
  final int nextId;

  MazeState({
    @required this.board,
    @required this.wordsToFind,
    @required this.nextId,
  });

  factory MazeState.emptyState() {
    return MazeState(
      board: null,
      wordsToFind: [],
      nextId: 0,
    );
  }

  MazeState copyWith({
    final Board board,
    final List<Word> wordsToFind,
    final int nextId,
  }) {
    return MazeState(
      board: board ?? this.board,
      wordsToFind: wordsToFind ?? this.wordsToFind,
      nextId: nextId ?? this.nextId,
    );
  }
}
