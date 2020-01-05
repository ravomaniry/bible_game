import 'package:equatable/equatable.dart';

class Cell with EquatableMixin {
  final int wordIndex;
  final int charIndex;

  Cell(this.wordIndex, this.charIndex);

  bool isSameAs(int w, int c) => w == wordIndex && c == charIndex;

  @override
  String toString() {
    return "$wordIndex $charIndex";
  }

  @override
  List<Object> get props {
    return [wordIndex, charIndex];
  }
}
