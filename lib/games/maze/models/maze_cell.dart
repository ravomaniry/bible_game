import 'package:bible_game/models/cell.dart';

enum CellEnv {
  none,
  forest,
  frontier,
  upLeft,
  upRight,
  downRight,
  downLeft,
}

class MazeCell {
  final List<Cell> cells;
  CellEnv environment = CellEnv.none;

  MazeCell(this.cells);

  factory MazeCell.create(int wIndex, int cIndex) {
    return MazeCell([Cell(wIndex, cIndex)]);
  }

  bool contains(int wIndex, int cIndex) {
    for (var i = 0, max = cells.length; i < max; i++) {
      if (cells[i].isSameAs(wIndex, cIndex)) {
        return true;
      }
    }
    return false;
  }

  MazeCell concat(int wIndex, int cIndex) {
    if (cells.length == 1 && cells.first.isSameAs(-1, -1)) {
      return MazeCell.create(wIndex, cIndex);
    } else {
      final nextCells = List<Cell>.from(cells)..add(Cell(wIndex, cIndex));
      return MazeCell(nextCells);
    }
  }

  forEach(void Function(Cell) callback) {
    cells.forEach(callback);
  }

  bool get isFree {
    return cells.length == 1 && contains(-1, -1);
  }

  bool get isFilled {
    return cells[0].wordIndex >= 0;
  }

  Cell get first {
    return cells.first;
  }

  Cell get last {
    return cells.last;
  }

  bool get isOverlapping {
    return cells.length > 1;
  }

  @override
  String toString() {
    return cells.map((c) => c.toString()).join(",");
  }
}
