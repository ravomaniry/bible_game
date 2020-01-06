import 'package:bible_game/models/cell.dart';

class Coordinate {
  final int x;
  final int y;

  Coordinate(this.x, this.y);

  static final up = Coordinate(0, -1);
  static final upRight = Coordinate(1, -1);
  static final right = Coordinate(1, 0);
  static final downRight = Coordinate(1, 1);
  static final down = Coordinate(0, 1);
  static final downLeft = Coordinate(-1, 1);
  static final left = Coordinate(-1, 0);
  static final upLeft = Coordinate(-1, -1);

  static final List<Coordinate> directionsList = [
    up,
    upRight,
    right,
    downRight,
    down,
    downLeft,
    left,
    upLeft,
  ];

  Coordinate clone() {
    return Coordinate(x, y);
  }

  Coordinate operator +(Coordinate delta) {
    return Coordinate(x + delta.x, y + delta.y);
  }

  Coordinate operator -(Coordinate delta) {
    return Coordinate(x - delta.x, y - delta.y);
  }

  Coordinate operator *(int n) {
    return Coordinate(x * n, y * n);
  }

  bool isSameAs(Coordinate c) {
    return c.x == x && c.y == y;
  }

  @override
  String toString() {
    return "($x, $y)";
  }
}

class Move {
  final Coordinate origin;
  final Coordinate direction;

  Move(this.origin, this.direction);

  @override
  String toString() {
    return "(${origin.x}, ${origin.y}, ${direction.x}, ${direction.y})";
  }
}

class MazeCell {
  final List<Cell> _cells;

  MazeCell(this._cells);

  factory MazeCell.create(int wIndex, int cIndex) {
    return MazeCell([Cell(wIndex, cIndex)]);
  }

  bool contains(int wIndex, int cIndex) {
    return _cells.where((c) => c.isSameAs(wIndex, cIndex)).isNotEmpty;
  }

  MazeCell concat(int wIndex, int cIndex) {
    if (_cells.length == 1 && _cells.first.isSameAs(-1, -1)) {
      return MazeCell.create(wIndex, cIndex);
    } else {
      final cells = List<Cell>.from(_cells)..add(Cell(wIndex, cIndex));
      return MazeCell(cells);
    }
  }

  forEach(void Function(Cell) callback) {
    _cells.forEach(callback);
  }

  bool get isFree {
    return _cells.length == 1 && contains(-1, -1);
  }

  Cell get first {
    return _cells.first;
  }

  bool get isOverlapping {
    return _cells.length > 1;
  }

  @override
  String toString() {
    return _cells.map((c) => c.toString()).join(",");
  }
}

class Board {
  final List<List<MazeCell>> value;

  Board(this.value);

  factory Board.create(int width, int height) {
    final generator = (int wIndex) {
      return List<MazeCell>.generate(height, (i) => MazeCell.create(-1, -1));
    };
    final value = List<List<MazeCell>>.generate(width, generator);
    return Board(value);
  }

  MazeCell getAt(int x, int y) => value[y][x];

  int get width {
    return value.isEmpty ? 0 : value[0].length;
  }

  int get height {
    return value.length;
  }

  bool isFreeAt(Coordinate c) {
    final cell = getAt(c.x, c.y);
    return cell.contains(-1, -1);
  }

  bool isIn(Coordinate coordinate) {
    return coordinate.x >= 0 && coordinate.x < width && coordinate.y >= 0 && coordinate.y < height;
  }

  forEach(void Function(Cell, int x, int y) callback) {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        getAt(x, y).forEach((cell) => callback(cell, x, y));
      }
    }
  }

  Coordinate coordinateOf(int wordIndex, int charIndex) {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (getAt(x, y).contains(wordIndex, charIndex)) {
          return Coordinate(x, y);
        }
      }
    }
    return null;
  }

  set(int x, int y, int wordIndex, int charIndex) {
    value[y][x] = value[y][x].concat(wordIndex, charIndex);
  }

  Board trim() {
    final rows = value
        .where(
          (row) => !rowIsEmpty(row),
        )
        .map((row) => List<MazeCell>.from(row))
        .toList();
    for (var column = width - 1; column >= 0; column--) {
      if (columnIsEmpty(column, rows)) {
        rows.forEach((cell) => cell.removeAt(column));
      }
    }
    return Board(rows.toList());
  }

  @override
  String toString() {
    return value.map((row) => row.join(" | ")).join("\n");
  }
}

bool rowIsEmpty(List<MazeCell> row) {
  return row.where((r) => !r.isFree).isEmpty;
}

bool columnIsEmpty(int column, List<List<MazeCell>> rows) {
  for (var i = 0; i < rows.length; i++) {
    if (!rows[i][column].isFree) {
      return false;
    }
  }
  return true;
}
