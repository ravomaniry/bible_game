import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/widgets.dart';

class MazeState {
  final Board board;
  final List<Word> wordsToFind;

  MazeState({
    @required this.board,
    @required this.wordsToFind,
  });

  factory MazeState.emptyState() {
    return MazeState(
      board: Board.create(10, 10),
      wordsToFind: [],
    );
  }

  MazeState copyWith({
    final Board board,
    final List<Word> wordsToFind,
  }) {
    return MazeState(
      board: board ?? this.board,
      wordsToFind: wordsToFind ?? this.wordsToFind,
    );
  }
}
