import 'dart:math';

import 'package:bible_game/games/maze/components/config.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/utils/pair.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final animationDuration = Duration(milliseconds: 600);

class Scroller {
  final _animationUnit = cellSize * 2;
  Offset origin = Offset(0, 0);
  Size _boardSize = Size(0, 0);
  Size containerSize = Size(0, 0);
  Board _board;
  bool isAnimating = false;
  Offset animationStart;
  Offset animationEnd;
  Function() reRender;

  void onScroll(PointerMoveEvent e) {
    if (!isAnimating) {
      final nextOrigin = getNextOffset(e.delta, origin, _boardSize, containerSize);
      if (nextOrigin != null) {
        origin = nextOrigin;
        reRender();
      }
    }
  }

  void handleScreenEdge(Offset localPosition) {
    if (isAnimating) {
      return;
    }

    final edgeLimit = cellSize * 2;
    final position = localPosition + origin;
    var direction = Coordinate(0, 0);

    if (position.dx < edgeLimit) {
      direction += Coordinate.right;
    } else if (position.dx > containerSize.width - edgeLimit) {
      direction += Coordinate.left;
    }
    if (position.dy < edgeLimit) {
      direction += Coordinate.down;
    } else if (position.dy > containerSize.height - edgeLimit) {
      direction += Coordinate.up;
    }

    if (direction != Coordinate(0, 0)) {
      direction = direction;
      final delta = Offset(_animationUnit * direction.x, _animationUnit * direction.y);
      final end = getNextOffset(delta, origin, _boardSize, containerSize);
      if (end != null && end != origin) {
        isAnimating = true;
        animationStart = origin;
        origin = end;
        animationEnd = end;
        reRender();
        scheduleAnimationEnd();
      }
    }
  }

  void scheduleAnimationEnd() async {
    await Future.delayed(animationDuration);
    isAnimating = false;
    animationStart = null;
    animationEnd = null;
    reRender();
  }

  void adjustBoardSize(Board board) {
    if (_board != board) {
      _board = board;
      _boardSize = Size(board.width * cellSize, board.height * cellSize);
    }
  }

  void updateContainerSize(BoxConstraints constraints) {
    // The size of the container does not change on runtime because screen orientation is always vertical
    if (containerSize == null ||
        containerSize.width != constraints.maxWidth ||
        containerSize.height != constraints.maxHeight) {
      containerSize = Size(constraints.maxWidth, constraints.maxHeight);
    }
  }
}

Offset getNextOffset(Offset delta, Offset current, Size boardSize, Size containerSize) {
  if (containerSize != null && containerSize.width > 0) {
    final x = current.dx;
    final y = current.dy;
    final minX = min(0.0, containerSize.width - boardSize.width);
    final minY = min(0.0, containerSize.height - boardSize.height);
    double nextX = max(minX, min(0, x + delta.dx).round().toDouble());
    double nextY = max(minY, min(0, y + delta.dy).round().toDouble());
    final nextMaxX = boardSize.width + nextX;
    final nextMaxY = boardSize.height + nextY;

    if (nextMaxX < containerSize.width) {
      nextX = x;
    }
    if (nextMaxY < containerSize.height) {
      nextY = y;
    }
    if (nextX != x || nextY != y) {
      return Offset(nextX, nextY);
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
