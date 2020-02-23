import 'dart:math';

import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/utils/pair.dart';

class Board {
  final List<List<MazeCell>> value;
  Coordinate start;
  Coordinate end;
  final int id;
  final _coordinateMap = Map<int, Map<int, Coordinate>>();

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
        for (final cell in getAt(x, y).cells) {
          callback(cell, x, y);
        }
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
    final map = _coordinateMap[wordIndex];
    if (map != null) {
      return map[charIndex];
    }
    return null;
  }

  set(int x, int y, int wordIndex, int charIndex) {
    value[y][x] = value[y][x].concat(wordIndex, charIndex);
    _updateCoordinateMap(x, y, wordIndex, charIndex);
  }

  void _updateCoordinateMap(int x, int y, int wordIndex, int charIndex) {
    Map<int, Coordinate> map = _coordinateMap[wordIndex];
    if (map == null) {
      map = Map();
      _coordinateMap[wordIndex] = Map<int, Coordinate>();
    }
    final coordinate = map[charIndex];
    if (coordinate == null) {
      _coordinateMap[wordIndex][charIndex] = Coordinate(x, y);
    }
  }

  Board trim() {
    final minMax = _getMinMaxCell();
    final first = minMax.first;
    final last = minMax.last;
    final nextValue = List<List<MazeCell>>(last.y - first.y + 1);
    for (var y = 0, max = last.y - first.y; y <= max; y++) {
      nextValue[y] = value[y + first.y].getRange(first.x, last.x + 1).toList();
    }
    return Board(nextValue, id)._adjustCoordinateMap(_coordinateMap, first * -1);
  }

  Board _adjustCoordinateMap(Map<int, Map<int, Coordinate>> map, Coordinate delta) {
    for (var wIndex = 0; wIndex < map.length; wIndex++) {
      _coordinateMap[wIndex] = Map<int, Coordinate>();
      for (var cIndex = 0, max = map[wIndex].length; cIndex < max; cIndex++) {
        _coordinateMap[wIndex][cIndex] = map[wIndex][cIndex] + delta;
      }
    }
    return this;
  }

  Pair<Coordinate, Coordinate> _getMinMaxCell() {
    var minX = width;
    var minY = height;
    var maxX = 0;
    var maxY = 0;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (!value[y][x].isFree) {
          minX = min(minX, x);
          maxX = max(maxX, x);
          minY = min(minX, y);
          maxY = max(maxY, y);
        }
      }
    }
    return Pair(Coordinate(minX, minY), Coordinate(maxX, maxY));
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
