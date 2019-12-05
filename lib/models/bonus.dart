import 'package:flutter/foundation.dart';

class Bonus {
  final String name;
  final int point;
  final int price;

  Bonus({
    @required this.name,
    @required this.point,
    @required this.price,
  });

  Bonus copyWith({String name, int point, int price}) {
    return Bonus(
      name: name ?? this.name,
      point: point ?? this.point,
      price: price ?? this.price,
    );
  }

  Bonus doublePriced() {
    return copyWith(price: price * 2);
  }
}

class Money extends Bonus {}

class RevealCharBonus extends Bonus {
  final int power;

  RevealCharBonus(this.power, int price) : super(name: power.toString(), point: 0, price: price);
}

class RevealCharBonus1 extends RevealCharBonus {
  RevealCharBonus1() : super(1, 5);
}

class RevealCharBonus2 extends RevealCharBonus {
  static final defaultPrice = 7;

  RevealCharBonus2() : super(2, 7);
}

class RevealCharBonus5 extends RevealCharBonus {
  static final defaultPrice = 10;

  RevealCharBonus5() : super(5, 10);
}

class RevealCharBonus10 extends RevealCharBonus {
  static final defaultPrice = 15;

  RevealCharBonus10() : super(10, 15);
}

class SolveOneTurn extends Bonus {
  SolveOneTurn() : super(name: "1", point: 0, price: 50);
}
