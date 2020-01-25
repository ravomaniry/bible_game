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
  double _xOffset = 0;
  double _yOffset = 0;
  double _boardWidth = 0;
  double _boardHeight = 0;
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
              top: _yOffset,
              left: _xOffset,
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
    if (_containerSize != null && _containerSize.width > 0) {
      double nextXOffset = min(0, _xOffset + e.delta.dx);
      double nextYOffset = min(0, _yOffset + e.delta.dy);
      final nextMaxX = _boardWidth + nextXOffset;
      final nextMaxY = _boardHeight + nextYOffset;

      if (nextMaxX <= _containerSize.width) {
        nextXOffset = _xOffset;
      }
      if (nextMaxY <= _containerSize.height) {
        nextYOffset = _yOffset;
      }
      if (nextXOffset != _xOffset || nextYOffset != _yOffset) {
        setState(() {
          _xOffset = nextXOffset;
          _yOffset = nextYOffset;
        });
      }
    }
  }

  void _adjustBoardSize(Board board) {
    if (board == null) {
      _containerSize = null;
    } else if (_prevBoard != board) {
      _prevBoard = board;
      _boardWidth = board.width * cellSize;
      _boardHeight = board.height * cellSize;
    }
  }

  void _setContainerSize() {
    if (_containerSize == null || _containerSize.width == 0) {
      _containerSize = _key.currentContext.size;
    }
  }
}
