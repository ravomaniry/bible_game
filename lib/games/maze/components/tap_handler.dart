import 'dart:math';

import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:flutter/widgets.dart';

class TapHandler {
  bool _shouldHandlerMove = false;
  Function() reRender;
  Offset originalStart;
  Offset lineStart;
  Offset lineEnd;
  List<Coordinate> selectedCells;

  void onPointerDown(PointerDownEvent e, Board board) {
    final tappedCell = getTappedCell(e.localPosition, board);
    _shouldHandlerMove = tappedCell != null;
    if (_shouldHandlerMove) {
      lineEnd = e.localPosition;
      originalStart = e.localPosition;
      lineStart = snapCursor(e.localPosition, e.localPosition);
      selectedCells = getSelectedCells(lineStart, lineEnd);
      reRender();
    }
  }

  bool onPointerMove(Offset localPosition) {
    if (_shouldHandlerMove) {
      final nextStart = snapCursor(originalStart, localPosition);
      final nextEnd = snapCursor(localPosition, originalStart);
      if (nextStart != lineStart || nextEnd != lineEnd) {
        lineStart = nextStart;
        lineEnd = nextEnd;
        selectedCells = getSelectedCells(lineStart, lineEnd);
        reRender();
      }
      return true;
    }
    return false;
  }

  void onPointerUp(PointerUpEvent e) {
    reRender();
    _shouldHandlerMove = false;
    lineStart = null;
    lineEnd = null;
    selectedCells = null;
  }
}

MazeCell getTappedCell(Offset localPosition, Board board) {
  final x = (localPosition.dx / cellSize).floor();
  final y = (localPosition.dy / cellSize).floor();
  if (board.includes(Coordinate(x, y))) {
    final cell = board.getAt(x, y);
    if (!cell.isFree) {
      return cell;
    }
  }
  return null;
}

Offset snapCursor(Offset point, Offset other) {
  final x = point.dx > other.dx
      ? cellSize * (point.dx / cellSize).ceil()
      : cellSize * (point.dx / cellSize).floor();
  final y = point.dy > other.dy
      ? cellSize * (point.dy / cellSize).ceil()
      : cellSize * (point.dy / cellSize).floor();
  return Offset(x, y);
}

List<Coordinate> getSelectedCells(Offset start, Offset end) {
  final diff = end - start;
  if (diff.dx.abs() <= cellSize || diff.dy.abs() <= cellSize || diff.dx.abs() == diff.dy.abs()) {
    final cells = List<Coordinate>();
    Offset delta = Offset(0, 0);

    if (diff.dx.abs() > cellSize && diff.dy.abs() > cellSize) {
      // diagonal
      delta = Offset(
        diff.dx > 0 ? cellSize : -cellSize,
        diff.dy > 0 ? cellSize : -cellSize,
      );
    } else if (diff.dx.abs() > cellSize) {
      // horizontal
      delta = Offset(diff.dx > 0 ? cellSize : -cellSize, 0);
      start = Offset(start.dx, min(start.dy, end.dy));
      end = Offset(end.dx, min(start.dy, end.dy));
    } else if (diff.dy.abs() > cellSize) {
      // vertical
      delta = Offset(0, diff.dy > 0 ? cellSize : -cellSize);
      end = Offset(min(start.dx, end.dx), end.dy);
      start = Offset(min(start.dx, end.dx), start.dy);
    }
    if (delta.dx == 0 && delta.dy == 0) {
      end = start + Offset(cellSize, cellSize);
      delta = Offset(cellSize, cellSize);
    }
    final adjustment = _getAdjustment(start, end);
    start += adjustment;
    end += adjustment;

    Offset point = start;
    while (point != end) {
      final cell = Coordinate((point.dx / cellSize).floor(), (point.dy / cellSize).floor());
      cells.add(cell);
      point += delta;
    }
    return cells;
  }
  return null;
}

Offset _getAdjustment(Offset start, Offset end) {
  final diff = end - start;
  if (diff.dx.abs() > cellSize && diff.dy.abs() > cellSize) {
    if (start.dx > end.dx && start.dy > end.dy) {
      return Offset(-cellSize, -cellSize);
    } else if (start.dx < end.dx && start.dy > end.dy) {
      return Offset(0, -cellSize);
    } else if (start.dx > end.dx && start.dy < end.dy) {
      return Offset(-cellSize, 0);
    }
  } else if (diff.dx.abs() > cellSize && start.dx > end.dx) {
    return Offset(-cellSize, 0);
  } else if (diff.dy.abs() > cellSize && start.dy > end.dy) {
    return Offset(0, -cellSize);
  }
  return Offset(0, 0);
}
