import 'dart:math';

import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/utils/pair.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Scroller {
  final _animationUnit = cellSize * 2;
  Size origin = Size(0, 0);
  Size _boardSize = Size(0, 0);
  Size _containerSize = Size(0, 0);
  Board _board;
  bool shouldAnimate = false;
  Size animationStart;
  Size animationEnd;
  Pair<Size, Size> screenLimit = Pair(Size(0, 0), Size(0, 0));
  Function() reRender;

  void onScroll(PointerMoveEvent e) {
    if (!shouldAnimate) {
      final offsets =
          getNextOffsets(Size(e.delta.dx, e.delta.dy), origin, _boardSize, _containerSize);
      if (offsets != null) {
        origin = offsets;
        reRender();
        _updateScreenLimit();
      }
    }
  }

  void handleScreenEdge(PointerMoveEvent e) {
    final edgeLimit = cellSize * 2;
    var direction = Coordinate(0, 0);
    if (e.localPosition.dx - origin.width < edgeLimit) {
      direction = Coordinate.right;
    } else if (e.localPosition.dx > _containerSize.width - origin.width - edgeLimit) {
      direction = Coordinate.left;
    }
    if (e.localPosition.dy - origin.height < edgeLimit) {
      direction = Coordinate(direction.x, 1);
    } else if (e.localPosition.dy > _containerSize.height - origin.height + edgeLimit) {
      direction = Coordinate(direction.x, -1);
    }
    if (direction != Coordinate(0, 0)) {
      direction = direction;
      final delta = Size(
        _animationUnit * direction.x,
        _animationUnit * direction.y,
      );
      animationEnd = getNextOffsets(delta, origin, _boardSize, _containerSize);
      if (animationEnd != origin) {
        shouldAnimate = true;
        animationStart = origin;
        reRender();
      }
    }
  }

  void onAnimationEnd() {
    shouldAnimate = false;
    origin = animationEnd;
    animationStart = null;
    animationEnd = null;
    reRender();
  }

  void adjustBoardSize(Board board) {
    if (_board != board) {
      _board = board;
      _boardSize = Size(board.width * cellSize, board.height * cellSize);
      _updateScreenLimit();
    }
  }

  void updateContainerSize(BoxConstraints constraints) {
    // The size of the container does not change on runtime because screen orientation is always vertical
    if (_containerSize == null ||
        _containerSize.width != constraints.maxWidth ||
        _containerSize.height != constraints.maxHeight) {
      _containerSize = Size(constraints.maxWidth, constraints.maxHeight);
      _updateScreenLimit();
    }
  }

  _updateScreenLimit() {
    final next = getOnScreenLimit(origin, _board, _containerSize);
    if (next != screenLimit) {
      screenLimit = next;
    }
  }
}

Size getNextOffsets(Size delta, Size current, Size boardSize, Size containerSize) {
  if (containerSize != null && containerSize.width > 0) {
    final x = current.width;
    final y = current.height;
    final minX = min(0.0, containerSize.width - boardSize.width);
    final minY = min(0.0, containerSize.height - boardSize.height);
    double nextX = max(minX, min(0, x + delta.width).round().toDouble());
    double nextY = max(minY, min(0, y + delta.height).round().toDouble());
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

// x € [x0, x1[ && y € [y0, y1[
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
