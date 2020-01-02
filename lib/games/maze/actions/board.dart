import 'dart:math';

import 'package:bible_game/models/word.dart';

int getMinSize(List<Word> words) {
  final wordsInScope = words.where((w) => !w.isSeparator);
  final lengths = wordsInScope.map((x) => x.chars.length);
  final maxLength = lengths.reduce(max);
  final totalLength = lengths.reduce((a, b) => a + b);
  return max(maxLength, (totalLength / 5).ceil());
}
