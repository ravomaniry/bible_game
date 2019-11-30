import 'package:bible_game/redux/error/state.dart';
import 'package:flutter/material.dart';

class Errors {
  static final dbNotReady = ErrorState("DB not ready", "Try restart the app!");
  static final unknownDbError = ErrorState("DB empty error", "Try restart the app");
}

class BibleGameColors {
  static final wordsSeparator = Color.fromARGB(100, 255, 255, 255);
  static final unrevealedWord = Color.fromARGB(255, 100, 100, 200);
  static final revealedWord = Color.fromARGB(255, 0, 200, 0);
  static final revealedChar = Color.fromARGB(255, 100, 240, 100);
  static final resultBackground = Color.fromARGB(255, 200, 230, 255);
  static final revealedCharStyle = TextStyle(color: Color.fromARGB(255, 255, 255, 255));
  static final revealedWordStyle = TextStyle(
    color: Color.fromARGB(255, 255, 255, 255),
    fontWeight: FontWeight.bold,
  );
}
