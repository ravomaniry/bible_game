import 'package:bible_game/games/maze/actions/board_utils.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';

final _tests = [
  MapEntry(CellEnv.forest, Coordinate.directionsList),
  MapEntry(CellEnv.upRight, [
    ...directionsExcept([Coordinate.downLeft]),
    ...translateCoordinatesBy(Coordinate.directionsList, Coordinate.up),
  ]),
  MapEntry(CellEnv.upRight, [
    ...directionsExcept([Coordinate.downLeft]),
    ...translateCoordinatesBy(Coordinate.directionsList, Coordinate.right),
  ]),
  MapEntry(CellEnv.downLeft, [
    ...directionsExcept([Coordinate.upRight]),
    ...translateCoordinatesBy(Coordinate.directionsList, Coordinate.left),
  ]),
  MapEntry(CellEnv.downLeft, [
    ...directionsExcept([Coordinate.upRight]),
    ...translateCoordinatesBy(Coordinate.directionsList, Coordinate.down),
  ]),
  MapEntry(CellEnv.upLeft, [
    ...directionsExcept([Coordinate.downRight]),
    ...translateCoordinatesBy(Coordinate.directionsList, Coordinate.up),
  ]),
  MapEntry(CellEnv.upLeft, [
    ...directionsExcept([Coordinate.downRight]),
    ...translateCoordinatesBy(Coordinate.directionsList, Coordinate.left),
  ]),
  MapEntry(CellEnv.downRight, [
    ...directionsExcept([Coordinate.upLeft]),
    ...translateCoordinatesBy(Coordinate.directionsList, Coordinate.right),
  ]),
  MapEntry(CellEnv.downRight, [
    ...directionsExcept([Coordinate.upLeft]),
    ...translateCoordinatesBy(Coordinate.directionsList, Coordinate.down),
  ]),
];

void addEnvironments(Board board) {
  for (var x = 0; x < board.width; x++) {
    for (var y = 0; y < board.height; y++) {
      _assignSingleCellWater(x, y, board);
    }
  }
  _assignBeaches(board);
}

void _assignSingleCellWater(int x, int y, Board board) {
  if (board.isFreeAt(Coordinate(x, y))) {
    final cell = board.getAt(x, y);
    for (final test in _tests) {
      if (_evaluateTest(x, y, test.value, board)) {
        cell.environment = test.key;
        return;
      }
    }
  }
}

bool _evaluateTest(int x, int y, List<Coordinate> directions, Board board) {
  final point = Coordinate(x, y);
  for (final direction in directions) {
    final neighbor = point + direction;
    if (board.includes(neighbor) && !board.isFreeAt(neighbor)) {
      return false;
    }
  }
  return true;
}

List<Coordinate> directionsExcept(List<Coordinate> toExclude) {
  return Coordinate.directionsList
      .where((d) => toExclude.where((x) => x.isSameAs(d)).isEmpty)
      .toList();
}

List<Coordinate> translateCoordinatesBy(List<Coordinate> points, Coordinate delta) {
  return points.map((p) => p + delta).toList();
}

void _assignBeaches(Board board) {
  for (var x = 0; x < board.width; x++) {
    for (var y = 0; y < board.height; y++) {
      final cell = board.getAt(x, y);
      if (cell.environment == CellEnv.forest) {
        final point = Coordinate(x, y);
        if (_isNeighborOf(point, CellEnv.none, board) ||
            _isNeighborOf(point, CellEnv.upLeft, board) ||
            _isNeighborOf(point, CellEnv.upRight, board) ||
            _isNeighborOf(point, CellEnv.downRight, board) ||
            _isNeighborOf(point, CellEnv.downLeft, board)) {
          cell.environment = CellEnv.frontier;
        }
      }
    }
  }
}

bool _isNeighborOf(Coordinate point, CellEnv waterType, Board board) {
  for (final neighbor in getNeighbors(point)) {
    if (board.includes(neighbor) && board.getAt(neighbor.x, neighbor.y).environment == waterType) {
      return true;
    }
  }
  return false;
}
