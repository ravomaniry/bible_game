import 'package:bible_game/models/bonus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Word with EquatableMixin {
  final Bonus bonus;
  final List<Char> chars;
  bool resolved;
  final int index;

  Word({this.chars, this.resolved = false, this.bonus, @required this.index});

  factory Word.from(String text, int index) {
    final chars = text.split("").map((t) => Char(value: t)).toList();
    return Word(chars: chars, index: index);
  }

  Word copyWith({List<Char> chars, bool resolved, Bonus bonus}) {
    return Word(
      index: this.index,
      chars: chars ?? this.chars,
      resolved: resolved ?? this.resolved,
      bonus: bonus ?? this.bonus,
    );
  }

  Word copyWithChar(int index, Char char) {
    final chars = List<Char>.from(this.chars)..[index] = char;
    return copyWith(chars: chars);
  }

  @override
  String toString() {
    return "${chars.map((x) => x.value).join('')} : ${chars.join(",")}, resolved=$resolved, bonus=$bonus";
  }

  @override
  List<Object> get props {
    return [chars, index, resolved, bonus];
  }
}

class Char with EquatableMixin {
  final String value;
  final bool resolved;
  final Bonus bonus;

  Char({@required this.value, this.resolved = false, this.bonus});

  Char copyWith({bool resolved, Bonus bonus}) {
    return Char(
      value: this.value,
      resolved: resolved ?? this.resolved,
      bonus: bonus ?? this.bonus,
    );
  }

  @override
  String toString() {
    return "value=$value, resolved=$resolved, bonus=$bonus";
  }

  @override
  List<Object> get props {
    return [value, resolved, bonus];
  }
}
