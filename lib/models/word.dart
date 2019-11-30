import 'package:bible_game/models/bonus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Word with EquatableMixin {
  final Bonus bonus;
  final List<Char> chars;
  final bool resolved;
  final bool isSeparator;
  final int index;

  Word({
    @required this.value,
    @required this.index,
    this.chars,
    this.resolved = false,
    this.isSeparator = false,
    this.bonus,
  });

  final String value;

  factory Word.from(String text, int index, bool isSeparator) {
    final chars = text.split("").map((t) => Char(value: t, comparisonValue: Char.getComparisonValue(t))).toList();
    return Word(
      chars: chars,
      index: index,
      isSeparator: isSeparator,
      resolved: isSeparator,
      value: text,
    );
  }

  Word copyWith({List<Char> chars, bool resolved, Bonus bonus}) {
    var nextValue = this.value;
    if (chars != null) {
      nextValue = chars.map((t) => t.value).join("");
    }
    return Word(
      index: this.index,
      value: nextValue,
      chars: chars ?? this.chars,
      resolved: resolved ?? this.resolved,
      bonus: bonus ?? this.bonus,
    );
  }

  Word copyWithChar(int index, Char char) {
    final chars = List<Char>.from(this.chars)..[index] = char;
    return copyWith(chars: chars);
  }

  bool sameAsChars(List<Char> chars) {
    if (chars.length == this.chars.length) {
      for (int i = 0; i < chars.length; i++) {
        if (chars[i].comparisonValue != this.chars[i].comparisonValue) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return "\n$value: isSeparator=$isSeparator resolved=$resolved, bonus=$bonus  \n\t[${chars.join(",\n\t")}]";
  }

  @override
  List<Object> get props {
    return [value, chars, index, isSeparator, resolved, bonus];
  }
}

class Char with EquatableMixin {
  final String value;
  final String comparisonValue;
  final bool resolved;
  final Bonus bonus;

  Char({@required this.value, @required this.comparisonValue, this.resolved = false, this.bonus});

  Char copyWith({bool resolved, Bonus bonus}) {
    return Char(
      value: this.value,
      comparisonValue: this.comparisonValue,
      resolved: resolved ?? this.resolved,
      bonus: bonus ?? this.bonus,
    );
  }

  static getComparisonValue(String value) {
    var comparisonValue = value.toLowerCase();
    if (comparisonValue == "à") {
      return "a";
    } else if (comparisonValue == "ô") {
      return "o";
    }
    return comparisonValue;
  }

  @override
  String toString() {
    return "{value:$value, comparisonValue:$comparisonValue resolved:$resolved, bonus:$bonus}";
  }

  @override
  List<Object> get props {
    return [value, comparisonValue, resolved, bonus];
  }
}
