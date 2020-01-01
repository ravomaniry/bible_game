import 'package:flutter/material.dart';

class AppColorTheme {
  final name = "pink_redish";
  final background = "assets/images/night.png";
  final primary = Color.fromARGB(255, 212, 38, 91);
  final primaryLight = Color.fromARGB(255, 255, 113, 156);
  final primaryDark = Color.fromARGB(255, 121, 0, 37);
  final accentRight = Color.fromARGB(255, 26, 186, 26);
  final accentRightDark = Color.fromARGB(255, 29, 94, 0);
  final accentLeft = Color.fromARGB(255, 0, 81, 255);
  final neutral = Color.fromARGB(255, 255, 255, 255);

  @override
  String toString() {
    return name;
  }
}

class BlueGrayTheme implements AppColorTheme {
  final name = "blue_gray";
  final background = "assets/images/blue_gray.jpg";
  final primary = Color.fromARGB(255, 0, 59, 254);
  final primaryLight = Color.fromARGB(255, 136, 164, 255);
  final primaryDark = Color.fromARGB(255, 28, 40, 80);
  final accentRight = Color.fromARGB(255, 0, 240, 20);
  final accentRightDark = Color.fromARGB(255, 8, 162, 0);
  final accentLeft = Color.fromARGB(255, 255, 0, 13);
  final neutral = Color.fromARGB(255, 255, 255, 255);

  @override
  String toString() {
    return name;
  }
}

class GreenTheme implements AppColorTheme {
  final name = "green";
  final background = "assets/images/green.jpg";
  final primary = Color.fromARGB(255, 73, 180, 0);
  final primaryLight = Color.fromARGB(255, 127, 236, 52);
  final primaryDark = Color.fromARGB(255, 35, 87, 0);
  final accentRight = Color.fromARGB(255, 255, 18, 115);
  final accentRightDark = Color.fromARGB(255, 132, 0, 54);
  final accentLeft = Color.fromARGB(255, 0, 103, 255);
  final neutral = Color.fromARGB(255, 255, 255, 255);

  @override
  String toString() {
    return super.toString();
  }
}
