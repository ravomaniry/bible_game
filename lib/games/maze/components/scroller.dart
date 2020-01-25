import 'dart:math';

import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/utils/pair.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef Builder = MazeBoard Function({
  Function(Board) adjustBoardSize,
  Function(PointerMoveEvent) onScroll,
  Pair<Size, Size> screenLimit,
});

class MazeBoardScroller extends StatefulWidget {
  final Builder builder;

  MazeBoardScroller({
    @required this.builder,
  });

  @override
  _MazeBoardScrollerState createState() => _MazeBoardScrollerState(builder: builder);
}

class _MazeBoardScrollerState extends State<MazeBoardScroller> {
  Size _origin = Size(0, 0);
  Size _boardSize = Size(0, 0);
  Size _containerSize = Size(0, 0);
  Board _board;
  Pair<Size, Size> _screenLimit = Pair(Size(0, 0), Size(0, 0));
  final Builder builder;
  final _key = GlobalKey();

  _MazeBoardScrollerState({
    @required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Color.fromARGB(255, 153, 208, 70),
        child: LayoutBuilder(
          builder: (_, constraints) {
            _updateContainerSize(constraints);
            return Stack(
              key: _key,
              overflow: Overflow.clip,
              children: [
                Positioned(
                  top: _origin.height,
                  left: _origin.width,
                  child: builder(
                    adjustBoardSize: _adjustBoardSize,
                    onScroll: _onScroll,
                    screenLimit: _screenLimit,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onScroll(PointerMoveEvent e) {
    final offsets = getNextOffsets(Size(e.delta.dx, e.delta.dy), _origin, _boardSize, _containerSize);
    if (offsets != null) {
      setState(() {
        _origin = offsets;
        _updateScreenLimit();
      });
    }
  }

  void _adjustBoardSize(Board board) {
    if (_board != board) {
      _board = board;
      _boardSize = Size(board.width * cellSize, board.height * cellSize);
      _updateScreenLimit();
    }
  }

  void _updateContainerSize(BoxConstraints constraints) {
    // The size of the container does not change on runtime because screen orientation is always vertical
    if (_containerSize == null ||
        _containerSize.width != constraints.maxWidth ||
        _containerSize.height != constraints.maxHeight) {
      _containerSize = Size(constraints.maxWidth, constraints.maxHeight);
      _updateScreenLimit();
    }
  }

  _updateScreenLimit() {
    _screenLimit = getOnScreenLimit(_origin, _board, _containerSize);
  }
}

Size getNextOffsets(Size delta, Size current, Size boardSize, Size containerSize) {
  if (containerSize != null && containerSize.width > 0) {
    final x = current.width;
    final y = current.height;
    final minX = min(0.0, containerSize.width - boardSize.width);
    final minY = min(0.0, containerSize.height - boardSize.height);
    double nextX = max(minX, min(0, x + delta.width));
    double nextY = max(minY, min(0, y + delta.height));
    final nextMaxX = boardSize.width + nextX;
    final nextMaxY = boardSize.height + nextY;

    if (nextMaxX < containerSize.width) {
      nextX = x;
    }
    if (nextMaxY < containerSize.height) {
      nextY = y;
    }
    if (nextX != x || nextY != y) {
      return Size(nextX, nextY);
    }
  }
  return null;
}

// this is [x, x1[ && [y, y1[
Pair<Size, Size> getOnScreenLimit(Size origin, Board board, Size containerSize) {
  if (board == null || containerSize == null) {
    return Pair(Size(0, 0), Size(1, 1));
  }
  final bottomLeft = origin * -1;
  final topRight = Size(
    containerSize.width - origin.width,
    containerSize.height - origin.height,
  );
  final minX = max(0.0, (bottomLeft.width / cellSize).floor().toDouble());
  final minY = max(0.0, (bottomLeft.height / cellSize).floor().toDouble());
  final maxX = min(board.width.toDouble(), (topRight.width / cellSize).ceil().toDouble());
  final maxY = min(board.height.toDouble(), (topRight.height / cellSize).ceil().toDouble());
  return Pair(Size(minX, minY), Size(maxX, maxY));
}
