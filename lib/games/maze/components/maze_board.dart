import 'package:bible_game/games/maze/components/background.dart';
import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/redux/view_model.dart';
import 'package:bible_game/utils/pair.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class MazeBoard extends StatelessWidget {
  final Function(Board) adjustBoardSize;
  final Pair<Size, Size> screenLimit;
  final Function(PointerDownEvent, Board) onPointerDown;
  final Function(PointerMoveEvent) onPointerMove;
  final Function(PointerUpEvent) onPointerUp;

  MazeBoard({
    @required this.adjustBoardSize,
    @required this.screenLimit,
    @required this.onPointerDown,
    @required this.onPointerMove,
    @required this.onPointerUp,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: MazeViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, MazeViewModel viewModel) {
    final board = viewModel.state.board;
    adjustBoardSize(board);
    if (board == null) {
      return _Loader();
    } else {
      return Listener(
        onPointerDown: (e) => onPointerDown(e, board),
        onPointerMove: onPointerMove,
        onPointerUp: onPointerUp,
        key: Key("maze_board"),
        child: AbsorbPointer(
          child: SizedBox(
            width: computeBoardPxWidth(board),
            height: computeBoardPxHeight(board),
            child: MazeBackground(viewModel),
          ),
        ),
      );
    }
  }
}

double computeBoardPxWidth(Board board) => board.width * cellSize;

double computeBoardPxHeight(Board board) => board.height * cellSize;

class _Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Loading..."),
    );
  }
}
