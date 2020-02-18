import 'package:bible_game/games/maze/components/cell.dart';
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

  void onPointerDown(PointerDownEvent e, Board board) {
    final tappedCell = getTappedCell(e.localPosition, board);
    _shouldHandlerMove = tappedCell != null;
    if (_shouldHandlerMove) {
      lineEnd = snapCursor(e.localPosition);
      lineStart = snapCursor(e.localPosition);
      selectedCells = getSelectedCells(lineStart, lineEnd);
      reRender();
    }
  }

  bool onPointerMove(Offset localPosition) {
    if (_shouldHandlerMove) {
      final nextEnd = snapCursor(localPosition);
      if (nextEnd != lineEnd) {
        lineEnd = nextEnd;
        selectedCells = getSelectedCells(lineStart, nextEnd);
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

Offset snapCursor(Offset point) {
  return Offset(_snapValue(point.dx), _snapValue(point.dy));
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
