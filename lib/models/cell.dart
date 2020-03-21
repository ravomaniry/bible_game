import 'package:flutter/cupertino.dart';

class Cell {
  final int wordIndex;
  final int charIndex;

  Cell(this.wordIndex, this.charIndex);

  bool isSameAs(int w, int c) => w == wordIndex && c == charIndex;

  @override
  String toString() {
    return "$wordIndex $charIndex";
  }

  @override
  int get hashCode => hashValues(wordIndex, charIndex);

  @override
  bool operator ==(other) {
    return other is Cell && other.wordIndex == wordIndex && other.charIndex == charIndex;
  }
}
