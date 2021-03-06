import 'package:flutter/cupertino.dart';

class Pair<F, L> {
  final F first;
  final L last;

  Pair(this.first, this.last);

  @override
  int get hashCode => hashValues(first, last);

  @override
  bool operator ==(other) {
    return other is Pair<F, L> && first == other.first && last == other.last;
  }

  @override
  String toString() {
    return "Pair(${first.toString()}, ${last.toString()})";
  }
}
