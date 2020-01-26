import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:flutter/widgets.dart';

class RowCaches {
  static var _caches = List<_BoardRowCache>();

  static Row get(int index, List<MazeCell> boardRow, int minX, int maxX) {
    if (_caches.length > index) {
      final cached = _caches[index];
      if (cached != null && cached.isSameAs(boardRow, minX, maxX)) {
        return _caches[index].widget;
      } else if (cached != null) {
        _caches[index] = null;
      }
    }
    return null;
  }

  static void set(int index, List<MazeCell> boardRow, int minX, int maxX, Row widget) {
    _createMissingCacheIndex(index);
    _caches[index] = _BoardRowCache(
      minX: minX,
      maxX: maxX,
      boardRow: boardRow,
      widget: widget,
    );
  }

  static void invalidate() {
    _caches = [];
  }

  static void _createMissingCacheIndex(int index) {
    while (_caches.length <= index) {
      _caches.add(null);
    }
  }
}

class _BoardRowCache {
  final List<MazeCell> boardRow;
  final int minX;
  final int maxX;
  final Row widget;

  _BoardRowCache({
    @required this.minX,
    @required this.maxX,
    @required this.boardRow,
    @required this.widget,
  });

  bool isSameAs(List<MazeCell> boardRow, int minX, int maxX) {
    return this.minX == minX && this.maxX == maxX && this.boardRow == boardRow;
  }
}
