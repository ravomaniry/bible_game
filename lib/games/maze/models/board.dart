import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';

class Board {
  final List<List<MazeCell>> value;
  Coordinate start;
  Coordinate end;
  final int id;

  Board(this.value, this.id);

  factory Board.create(int width, int height, int id) {
    final generator = (int wIndex) {
      return List<MazeCell>.generate(width, (i) => MazeCell.create(-1, -1));
    };
    final value = List<List<MazeCell>>.generate(height, generator);
    return Board(value, id);
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

  bool includes(Coordinate coordinate) {
    return coordinate.x >= 0 && coordinate.x < width && coordinate.y >= 0 && coordinate.y < height;
  }

  forEach(void Function(Cell, int x, int y) callback) {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        getAt(x, y).forEach((cell) => callback(cell, x, y));
      }
    }
  }

  forEachMazeCell(void Function(MazeCell) callback) {
    for (final row in value) {
      for (final cell in row) {
        callback(cell);
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
    return Board(rows.toList(), id);
  }

  @override
  String toString() {
    return value.map((row) => row.join(" | ")).join("\n");
  }

  void printWith(List<Word> words) {
    final grid = value
        .map((row) => row.map((cell) {
              if (cell.first.wordIndex >= 0) {
                return words[cell.first.wordIndex].chars[cell.first.charIndex].comparisonValue;
              }
              switch (cell.environment) {
                case CellEnv.forest:
                  return "*";
                case CellEnv.upRight:
                case CellEnv.downLeft:
                  return "\\";
                case CellEnv.upLeft:
                case CellEnv.downRight:
                  return "/";
                default:
                  return " ";
              }
            }).join(" "))
        .join("\n");
    print(grid);
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
