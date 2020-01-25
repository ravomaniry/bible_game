import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/redux/view_model.dart';
import 'package:bible_game/utils/pair.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class MazeBoard extends StatelessWidget {
  final Function(PointerMoveEvent) onScroll;
  final Function(Board) adjustBoardSize;
  final Pair<Size, Size> screenLimit;

  MazeBoard({
    @required this.onScroll,
    @required this.adjustBoardSize,
    @required this.screenLimit,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: MazeViewModel.converter,
      builder: (context, viewModel) => _BoardBody(
        viewModel: viewModel,
        onScroll: onScroll,
        onScreenLimit: screenLimit,
        adjustBoardSize: adjustBoardSize,
      ),
    );
  }
}

class _BoardBody extends StatelessWidget {
  final Function(PointerMoveEvent) onScroll;
  final Function(Board) adjustBoardSize;
  final Pair<Size, Size> onScreenLimit;
  final MazeViewModel viewModel;

  _BoardBody({
    @required this.viewModel,
    @required this.onScroll,
    @required this.adjustBoardSize,
    @required this.onScreenLimit,
  });

  void _onPointerDown(PointerDownEvent e) {
    print("Pointer down ${e.delta}");
  }

  void _onPointerMove(PointerMoveEvent e) {
    onScroll(e);
  }

  double get _width => viewModel.state.board.width * cellSize;

  double get _height => viewModel.state.board.height * cellSize;

  @override
  Widget build(BuildContext context) {
    adjustBoardSize(viewModel.state.board);
    if (viewModel.state.board == null) {
      return _Loader();
    } else {
      return Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        child: AbsorbPointer(
          child: SizedBox(
            width: _width,
            height: _height,
            child: Column(
              children: _buildRows(),
            ),
          ),
        ),
      );
    }
  }

  List<Widget> _buildRows() {
    final minX = onScreenLimit.first.width.toInt();
    final minY = onScreenLimit.first.height.toInt();
    final maxX = onScreenLimit.last.width.toInt();
    final maxY = onScreenLimit.last.height.toInt();
    final rows = List<Row>(maxY);
    for (var y = 0; y < maxY; y++) {
      if (y < minY) {
        rows[y] = Row(children: [emptyCell]);
      } else {
        final children = List<Widget>(maxX);
        for (var x = 0; x < maxX; x++) {
          if (x < minX) {
            children[x] = emptyCell;
          } else {
            children[x] = MazeCellWidget(
              theme: viewModel.theme,
              cell: viewModel.state.board.getAt(x, y),
              wordsToFind: viewModel.state.wordsToFind,
            );
          }
        }
        rows[y] = Row(children: children);
      }
    }
    return rows;
  }
}

class _Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Loading..."),
    );
  }
}
