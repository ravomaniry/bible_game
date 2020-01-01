import 'package:badges/badges.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/app/inventory/reducer/state.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final List<Bonus> _bonusesList = [
  RevealCharBonus1(),
  RevealCharBonus2(),
  RevealCharBonus5(),
  RevealCharBonus10(),
];

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
      children: [
        _BonusesRow(
          theme: theme,
          children: <Widget>[
            _buildBonus(_bonusesList[0]),
            _buildBonus(_bonusesList[1]),
          ],
        ),
        _BonusesRow(
          theme: theme,
          children: <Widget>[
            _buildBonus(_bonusesList[2]),
            _buildBonus(_bonusesList[3]),
          ],
        ),
      ],
    );
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

class _BonusesRow extends StatelessWidget {
  final AppColorTheme theme;
  final List<Widget> children;

  _BonusesRow({
    @required this.theme,
    @required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
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
    return Container(
      margin: EdgeInsets.only(bottom: 10, right: 10),
      child: RevealCharBonusDisplay(
        bonus: bonus,
        number: _number,
        disabled: false,
        theme: theme,
        onPressed: () => buy(bonus),
      ),
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
