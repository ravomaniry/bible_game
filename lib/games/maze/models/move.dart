import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:flutter/cupertino.dart';

class Move {
  final Coordinate origin;
  final Coordinate direction;
  final int wordIndex;
  final int length;
  final Coordinate overlapAt;

  Move(this.origin, this.direction, this.wordIndex, this.length, {this.overlapAt});

  bool isSameAs(Move m) {
    return m.origin.isSameAs(origin) && m.direction.isSameAs(direction);
  }

  Coordinate get end {
    return origin + direction * (length - 1);
  }

  @override
  String toString() {
    return "(${origin.x}, ${origin.y}, ${direction.x}, ${direction.y}, $wordIndex, $length)";
  }

  @override
  int get hashCode => hashValues(origin, direction, wordIndex, length, overlapAt);

  @override
  bool operator ==(other) =>
      other is Move &&
      other.origin == origin &&
      other.direction == direction &&
      other.wordIndex == wordIndex &&
      other.length == length &&
      other.overlapAt == overlapAt;
}
