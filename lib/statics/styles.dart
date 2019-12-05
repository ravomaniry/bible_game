import 'package:flutter/material.dart';

class WordInWordsStyles {
  static final wordsSeparatorColor = Color.fromARGB(100, 255, 255, 255);
  static final unrevealedWordColor = Color.fromARGB(255, 100, 100, 200);
  static final revealedWordColor = Color.fromARGB(255, 0, 200, 0);
  static final revealedCharColor = Color.fromARGB(255, 100, 100, 250);
  static final resultBackgroundColor = Color.fromARGB(255, 230, 230, 255);
  static final revealedCharStyle = TextStyle(color: Color.fromARGB(255, 255, 255, 255));
  static final separatorCharStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  static final revealedWordStyle = TextStyle(
    color: Color.fromARGB(255, 255, 255, 255),
    fontWeight: FontWeight.bold,
  );

  static final visitedSlotDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    color: Color.fromARGB(255, 160, 160, 160),
    border: Border.all(color: Color.fromARGB(255, 100, 100, 100)),
  );
  static final availSlotDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    color: Color.fromARGB(255, 100, 100, 200),
    border: Border.all(color: Color.fromARGB(255, 80, 80, 160)),
  );
  static final slotTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
  static final propositionStyle = TextStyle(
    color: Colors.white,
    letterSpacing: 1,
  );
}

class InventoryStyles {
  static final outerDecoration = BoxDecoration(
    color: Color.fromARGB(100, 0, 0, 0),
  );

  static final innerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(6),
  );
}
