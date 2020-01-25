import 'dart:math';

import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef Builder = BoardBody Function({
  Function(Board) adjustBoardSize,
  Function(PointerMoveEvent) onScroll,
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
  Size _offsets = Size(0, 0);
  Size _boardSize = Size(0, 0);
  Size _containerSize = Size(0, 0);
  Board _prevBoard;
  final _key = GlobalKey();
  final Builder builder;

  _MazeBoardScrollerState({
    @required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Color.fromARGB(255, 153, 208, 70),
        child: Stack(
          key: _key,
          overflow: Overflow.clip,
          children: [
            Positioned(
              top: _offsets.height,
              left: _offsets.width,
              child: builder(
                adjustBoardSize: _adjustBoardSize,
                onScroll: _onScroll,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onScroll(PointerMoveEvent e) {
    _setContainerSize();
    final offsets = getNextOffsets(Size(e.delta.dx, e.delta.dy), _offsets, _boardSize, _containerSize);
    if (offsets != null) {
      setState(() {
        _offsets = offsets;
      });
    }
  }

  void _adjustBoardSize(Board board) {
    if (board == null) {
      _containerSize = null;
    } else if (_prevBoard != board) {
      _prevBoard = board;
      _boardSize = Size(board.width * cellSize, board.height * cellSize);
    }
  }

  void _setContainerSize() {
    // The size of the container does not change on runtime because screen orientation is always vertical
    if (_containerSize == null || _containerSize.width == 0) {
      _containerSize = _key.currentContext.size;
    }
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
