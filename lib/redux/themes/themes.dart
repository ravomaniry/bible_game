import 'package:flutter/material.dart';

class AppColorTheme {
  final name = "pink_redish";
  final background = "assets/images/night.png";
  final primary = const Color.fromARGB(255, 212, 38, 91);
  final primaryLight = const Color.fromARGB(255, 255, 113, 156);
  final primaryDark = const Color.fromARGB(255, 121, 0, 37);
  final accentRight = const Color.fromARGB(255, 26, 186, 26);
  final accentRightDark = const Color.fromARGB(255, 29, 94, 0);
  final accentLeft = const Color.fromARGB(255, 0, 81, 255);
  final neutral = const Color.fromARGB(255, 255, 255, 255);

  @override
  String toString() {
    return name;
  }
}

class BlueGrayTheme implements AppColorTheme {
  final name = "blue_gray";
  final background = "assets/images/blue_gray.jpg";
  final primary = const Color.fromARGB(255, 0, 59, 254);
  final primaryLight = const Color.fromARGB(255, 136, 164, 255);
  final primaryDark = const Color.fromARGB(255, 28, 40, 80);
  final accentRight = const Color.fromARGB(255, 14, 241, 0);
  final accentRightDark = const Color.fromARGB(255, 9, 164, 0);
  final accentLeft = const Color.fromARGB(255, 255, 0, 13);
  final neutral = const Color.fromARGB(255, 255, 255, 255);

  @override
  String toString() {
    return name;
  }
}
