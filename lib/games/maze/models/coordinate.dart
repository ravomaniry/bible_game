import 'package:flutter/cupertino.dart';

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

  static final List<Coordinate> allDirections = [
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
    if (c == null) {
      return false;
    } else {
      return c.x == x && c.y == y;
    }
  }

  @override
  int get hashCode => hashValues(x, y);

  @override
  bool operator ==(other) => other is Coordinate && other.x == x && other.y == y;

  @override
  String toString() {
    return "($x, $y)";
  }
}
