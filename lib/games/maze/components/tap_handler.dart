import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:flutter/widgets.dart';

class TapHandler {
  Board _board;
  bool _shouldHandlerMove = false;
  List<MazeCell> _selectedCell = [];
  Function() reRender;
  Offset lineStart;
  Offset lineEnd;

  void onPointerDown(PointerDownEvent e, Board board) {
    _board = board;
    final tappedCell = getTappedCell(e.localPosition, board);
    _shouldHandlerMove = tappedCell != null;
    if (_shouldHandlerMove) {
      lineStart = e.localPosition;
      _selectedCell = [tappedCell];
      reRender();
    }
  }

  bool onPointerMove(PointerMoveEvent e) {
    if (_shouldHandlerMove) {
      lineEnd = e.localPosition;
      final tapped = getTappedCell(e.localPosition, _board);
      if (tapped != null && !_selectedCell.contains(tapped)) {
        _selectedCell.add(tapped);
      }
      reRender();
      return true;
    }
    return false;
  }

  void onPointerUp(PointerUpEvent e) {
    // fire submit event here
    _board = null;
    _selectedCell = [];
    reRender();
    _shouldHandlerMove = false;
    lineStart = null;
    lineEnd = null;
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
