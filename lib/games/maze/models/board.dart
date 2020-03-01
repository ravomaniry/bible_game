import 'dart:math';

import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/utils/pair.dart';

class Board {
  List<List<MazeCell>> _value;
  Coordinate start;
  Coordinate end;
  final int id;
  final _coordinateMap = Map<int, Map<int, Coordinate>>();
  List<List<List<List<Coordinate>>>> _moves = List();

  var _activeMove = Pair(Coordinate(-1, -1), -1);

  Board(this._value, this.id);

  factory Board.create(int width, int height, int id) {
    final value = List<List<MazeCell>>(height);
    for (var y = 0; y < height; y++) {
      value[y] = List<MazeCell>(width);
      for (var x = 0; x < width; x++) {
        value[y][x] = MazeCell.create(-1, -1);
      }
    }
    final board = Board(value, id);
    board._createEmptyMoves(width, height);
    return board;
  }

  List<List<List<List<Coordinate>>>> get moves => _moves;

  List<List<MazeCell>> get value => _value;

  int get width {
    return _value.isEmpty ? 0 : _value[0].length;
  }

  int get height {
    return _value.length;
  }

  MazeCell getAt(int x, int y) => _value[y][x];

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
    for (final row in _value) {
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
    _value[y][x] = _value[y][x].concat(wordIndex, charIndex);
    _updateCoordinateMap(x, y, wordIndex, charIndex);
    _appendMove(x, y);
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

  void trim() {
    final minMax = _getMinMaxCell();
    final first = minMax.first;
    final last = minMax.last;
    final delta = first * -1;
    final nextValue = List<List<MazeCell>>(last.y - first.y + 1);
    final nextMovesList = List<List<List<List<Coordinate>>>>.from(_moves);
    for (var y = 0, max = last.y - first.y; y <= max; y++) {
      nextValue[y] = _value[y + first.y].getRange(first.x, last.x + 1).toList();
      nextMovesList[y] = _moves[y + first.y].getRange(first.x, last.x + 1).toList();
    }
    _value = nextValue;
    _moves = nextMovesList;
    _adjustCoordinateMap(delta);
    _adjustMoves(delta);
  }

  void _adjustCoordinateMap(Coordinate delta) {
    for (var wIndex = 0; wIndex < _coordinateMap.length; wIndex++) {
      for (var cIndex = 0, max = _coordinateMap[wIndex].length; cIndex < max; cIndex++) {
        _coordinateMap[wIndex][cIndex] += delta;
      }
    }
  }

  void _createEmptyMoves(int width, int height) {
    for (var y = 0; y < height; y++) {
      moves.add(List<List<List<Coordinate>>>(width));
      for (var x = 0; x < width; x++) {
        moves[y][x] = [];
      }
    }
  }

  void startMove(Coordinate start) {
    _activeMove = Pair(start, moves[start.y][start.x].length);
    moves[start.y][start.x].add([]);
  }

  void _appendMove(int x, int y) {
    final point = _activeMove.first;
    moves[point.y][point.x][_activeMove.last].add(Coordinate(x, y));
  }

  void _adjustMoves(Coordinate delta) {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final cellMoves = moves[y][x];
        for (final row in cellMoves) {
          for (var i = 0; i < row.length; i++) {
            row[i] += delta;
          }
        }
      }
    }
  }

  Pair<Coordinate, Coordinate> _getMinMaxCell() {
    var minX = width;
    var minY = height;
    var maxX = 0;
    var maxY = 0;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (_value[y][x].isFilled) {
          minX = min(minX, x);
          maxX = max(maxX, x);
          minY = min(minY, y);
          maxY = max(maxY, y);
        }
      }
    }
    return Pair(Coordinate(minX, minY), Coordinate(maxX, maxY));
  }

  void updateStartEnd(List<Word> words) {
    start = coordinateOf(0, 0);
    end = coordinateOf(words.length - 1, words.last.length - 1);
  }

  @override
  String toString() {
    return _value.map((row) => row.join(" | ")).join("\n");
  }

  void printWith(List<Word> words) {
    final grid = _value
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
