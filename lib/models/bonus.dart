import 'package:flutter/foundation.dart';

class Bonus {
  final String name;
  final int point;

  Bonus({@required this.name, @required this.point});
}

class RevealCharBonus extends Bonus {
  RevealCharBonus() : super(name: "Reveal charachter", point: 0);
}
