import 'package:flutter/material.dart';

class AppColorTheme {
  final Color primary = const Color.fromARGB(255, 212, 38, 91);
  final Color primaryLight = const Color.fromARGB(255, 255, 113, 156);
  final Color primaryDark = const Color.fromARGB(255, 121, 0, 37);
  final Color accentRight = const Color.fromARGB(255, 26, 186, 26);
  final Color accentRightDark = const Color.fromARGB(255, 29, 94, 0);
  final Color accentLeft = const Color.fromARGB(255, 0, 81, 255);
  final Color neutral = const Color.fromARGB(255, 255, 255, 255);
  final String background = "assets/images/night.png";
}

class BlueGrayTheme extends AppColorTheme {
  @override
  final String background = "assets/images/blue_gray.jpg";
  @override
  final Color primaryDark = const Color.fromARGB(255, 28, 40, 80);
  @override
  final Color primary = const Color.fromARGB(255, 0, 59, 254);
  @override
  final Color neutral = const Color.fromARGB(255, 255, 202, 98);
}
