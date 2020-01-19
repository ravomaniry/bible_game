import 'package:bible_game/models/cell.dart';

enum CellWater {
  none,
  full,
  beach,
  upLeft,
  upRight,
  downRight,
  downLeft,
}

class MazeCell {
  final List<Cell> cells;
  CellWater water = CellWater.none;

  MazeCell(this.cells);

  factory MazeCell.create(int wIndex, int cIndex) {
    return MazeCell([Cell(wIndex, cIndex)]);
  }

  bool contains(int wIndex, int cIndex) {
    return cells.where((c) => c.isSameAs(wIndex, cIndex)).isNotEmpty;
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
