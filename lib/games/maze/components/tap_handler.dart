import 'dart:math';

import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/create/board_utils.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:flutter/widgets.dart';

class TapHandler {
  Function(List<Coordinate>) propose;
  bool _shouldHandlerMove = false;
  Function() reRender;
  Offset lineStart;
  Offset lineEnd;
  List<Coordinate> selectedCells;

  void onPointerDown(Offset localPosition, Board board) {
    final tappedCell =
        getTappedCell(localPosition, board) ?? _getTappedNearestNeighbor(localPosition, board);
    _shouldHandlerMove = tappedCell != null;
    if (_shouldHandlerMove) {
      lineEnd = snapCursor(localPosition, board);
      lineStart = snapCursor(localPosition, board);
      selectedCells = getSelectedCells(lineStart, lineEnd);
      reRender();
    }
  }

  bool onPointerMove(Offset localPosition, Board board) {
    if (_shouldHandlerMove) {
      final nextEnd = snapCursor(localPosition, board);
      if (nextEnd != lineEnd) {
        lineEnd = nextEnd;
        selectedCells = getSelectedCells(lineStart, nextEnd);
        reRender();
      }
      return true;
    }
    return false;
  }

  void onPointerUp(_) {
    reRender();
    _shouldHandlerMove = false;
    lineStart = null;
    lineEnd = null;
    if (selectedCells != null && selectedCells.isNotEmpty) {
      propose(selectedCells);
    }
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

double _snapValue(double value) {
  return value - (value % cellSize) + cellSize / 2;
}

Offset snapCursor(Offset position, Board board) {
  final tapped = getTappedCell(position, board);
  if (tapped == null) {
    final neighbor = _getTappedNearestNeighbor(position, board);
    if (neighbor != null) {
      position = _getCenterPositionOf(neighbor);
    }
  }
  return Offset(_snapValue(position.dx), _snapValue(position.dy));
}

Coordinate _getTappedNearestNeighbor(Offset position, Board board) {
  final coordinate = Coordinate((position.dx / cellSize).floor(), (position.dy / cellSize).floor());
  final neighbors = getNeighbors(coordinate);
  Coordinate nearest;
  var minDistance = pow(cellSize, 2) * 2;
  for (final neighbor in neighbors) {
    final distance = _squaredDiff(position, _getCenterPositionOf(neighbor));
    if (minDistance > distance) {
      minDistance = distance;
      if (board.includes(neighbor) && !board.isFreeAt(neighbor)) {
        nearest = neighbor;
      }
    }
  }
  return nearest;
}

double _squaredDiff(Offset a, Offset b) {
  return pow(a.dx - b.dx, 2) + pow(a.dy - b.dy, 2);
}

Offset _getCenterPositionOf(Coordinate point) {
  return Offset(
    cellSize * (point.x + 0.5),
    cellSize * (point.y + 0.5),
  );
}

List<Coordinate> getSelectedCells(Offset start, Offset end) {
  final diff = end - start;
  if (diff.dx == 0 || diff.dy == 0 || diff.dx.abs() == diff.dy.abs()) {
    final delta = _getDelta(diff);
    final List<Coordinate> cells = [_getCell(start)];
    var point = start;
    while (point != end) {
      point += delta;
      cells.add(_getCell(point));
    }
    return cells;
  }
  return null;
}

int _offsetToCell(double x) {
  return (x - cellSize / 2) ~/ cellSize;
}

Coordinate _getCell(Offset point) {
  return Coordinate(_offsetToCell(point.dx), _offsetToCell(point.dy));
}

Offset _getDelta(Offset diff) {
  var direction = Coordinate(0, 0);
  if (diff.dx > 0) {
    direction += Coordinate.right;
  } else if (diff.dx < 0) {
    direction += Coordinate.left;
  }
  if (diff.dy > 0) {
    direction += Coordinate.down;
  } else if (diff.dy < 0) {
    direction += Coordinate.up;
  }
  return Offset(direction.x * cellSize, direction.y * cellSize);
}
