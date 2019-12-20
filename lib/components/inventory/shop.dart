import 'package:badges/badges.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final List<Bonus> normalPricedBonuses = [
  RevealCharBonus1(),
  RevealCharBonus2(),
  RevealCharBonus5(),
  RevealCharBonus10(),
];

final List<Bonus> doublePricedBonuses = normalPricedBonuses.map((b) => b.doublePriced()).toList();

class Shop extends StatelessWidget {
  final InventoryState state;
  final Function(Bonus) buyBonus;
  final AppColorTheme theme;

  Shop({
    @required this.state,
    @required this.buyBonus,
    @required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: _bonusesList.map(_buildBonus).toList(),
        ),
        _Balance(state.money),
      ],
    );
  }

  List<Bonus> get _bonusesList {
    if (state.isInGame) {
      return doublePricedBonuses;
    }
    return normalPricedBonuses;
  }

  Widget _buildBonus(Bonus bonus) {
    if (bonus is RevealCharBonus) {
      return _RevealCharDisplayWrapper(
        state: state,
        bonus: bonus,
        buy: buyBonus,
        theme: theme,
      );
    } else if (bonus is SolveOneTurn) {
      return _SolveOneTurnDisplay(state, bonus, buyBonus);
    }
    return SizedBox.shrink();
  }
}

class _RevealCharDisplayWrapper extends StatelessWidget {
  final InventoryState state;
  final RevealCharBonus bonus;
  final Function(Bonus) buy;
  final AppColorTheme theme;

  _RevealCharDisplayWrapper({
    this.state,
    this.bonus,
    this.buy,
    this.theme,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RevealCharBonusDisplay(
      bonus: bonus,
      number: _number,
      disabled: false,
      theme: theme,
      onPressed: () => buy(bonus),
    );
  }

  int get _number {
    if (bonus is RevealCharBonus1) {
      return state.revealCharBonus1;
    } else if (bonus is RevealCharBonus2) {
      return state.revealCharBonus2;
    } else if (bonus is RevealCharBonus5) {
      return state.revealCharBonus5;
    } else if (bonus is RevealCharBonus10) {
      return state.revealCharBonus10;
    }
    return 0;
  }
}

class RevealCharBonusDisplay extends StatelessWidget {
  final int number;
  final bool disabled;
  final RevealCharBonus bonus;
  final Function() onPressed;
  final AppColorTheme theme;

  RevealCharBonusDisplay({
    @required this.bonus,
    @required this.number,
    @required this.disabled,
    @required this.onPressed,
    @required this.theme,
  });

  double get _opacity {
    return disabled ? 0.4 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacity,
      child: Container(
        width: 38,
        height: 32,
        margin: EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: Color.fromARGB(100, 255, 255, 255),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Color.fromARGB(255, 220, 220, 220),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.only(left: 4, right: 4),
        child: FlatButton(
          padding: EdgeInsets.all(0),
          key: Key("revealCharBonusBtn_${bonus.power}"),
          onPressed: onPressed,
          child: _buildBadge(),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    if (number > 0) {
      return Badge(
        badgeContent: Text(
          "$number",
          style: TextStyle(color: theme.neutral),
        ),
        badgeColor: theme.primaryDark,
        child: Image(
          fit: BoxFit.fitWidth,
          image: AssetImage("assets/images/wood_medal_${bonus.power}.png"),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(6),
      child: Image(
        fit: BoxFit.fitWidth,
        image: AssetImage("assets/images/wood_medal_${bonus.power}.png"),
      ),
    );
  }
}

class _SolveOneTurnDisplay extends StatelessWidget {
  final InventoryState _state;
  final SolveOneTurn _bonus;
  final Function(Bonus) _buy;

  _SolveOneTurnDisplay(this._state, this._bonus, this._buy, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        key: Key("solveOneTurnBonusBtn"),
        onPressed: () => _buy(_bonus),
        child: Badge(
          badgeContent: Text("${_state.solveOneTurnBonus}"),
          child: Container(
            padding: EdgeInsets.only(top: 14),
            child: Text(_bonus.name),
          ),
        ),
      ),
    );
  }
}

class _Balance extends StatelessWidget {
  final int _money;

  _Balance(this._money);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text("$_money Ar."),
    );
  }
}
