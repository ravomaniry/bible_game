import 'package:bible_game/models/bonus.dart';
import 'package:flutter/foundation.dart';

class WordsInWordChar {
  final String value;
  final bool pressed;
  final Bonus bonus;

  WordsInWordChar({
    @required this.value,
    this.pressed = false,
    this.bonus,
  });
}
