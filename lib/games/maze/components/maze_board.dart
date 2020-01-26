import 'package:bible_game/games/maze/components/cache.dart';
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
            width: _computeBoardPxWidth(board),
            height: _computeBoardPxHeight(board),
            child: Column(
              children: buildRows(screenLimit, viewModel),
            ),
          ),
        ),
      );
    }
  }
}

double _computeBoardPxWidth(Board board) => board.width * cellSize;

double _computeBoardPxHeight(Board board) => board.height * cellSize;

List<Row> buildRows(Pair<Size, Size> screenLimit, MazeViewModel viewModel) {
  final minX = screenLimit.first.width.toInt();
  final minY = screenLimit.first.height.toInt();
  final maxX = screenLimit.last.width.toInt();
  final maxY = screenLimit.last.height.toInt();
  final rows = List<Row>(maxY);
  for (var y = 0; y < maxY; y++) {
    if (y < minY) {
      rows[y] = Row(
        key: Key(y.toString()),
        children: [emptyCell],
      );
    } else {
      final boardRow = viewModel.state.board.value[y];
      rows[y] = RowCaches.get(y, boardRow, minX, maxX);
      if (rows[y] == null) {
        final children = List<Widget>(maxX);
        for (var x = 0; x < maxX; x++) {
          if (x < minX) {
            children[x] = emptyCell;
          } else {
            children[x] = MazeCellWidget(
              key: Key("$y,$x"),
              theme: viewModel.theme,
              cell: viewModel.state.board.getAt(x, y),
              wordsToFind: viewModel.state.wordsToFind,
            );
          }
        }
        rows[y] = Row(
          key: Key(y.toString()),
          children: children,
        );
      }
      RowCaches.set(y, boardRow, minX, maxX, rows[y]);
    }
  }
  return rows;
}

class _Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Loading..."),
    );
  }
}
