import 'package:badges/badges.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/redux/inventory/state.dart';
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
  final InventoryState _state;

  final Function(Bonus) _buyBonus;

  Shop(this._state, this._buyBonus);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: _bonusesList.map(_buildBonus).toList(),
        ),
        _Balance(_state.money),
      ],
    );
  }

  List<Bonus> get _bonusesList {
    if (_state.isInGame) {
      return doublePricedBonuses;
    }
    return normalPricedBonuses;
  }

  Widget _buildBonus(Bonus bonus) {
    if (bonus is RevealCharBonus) {
      return _RevealCharDisplayWrapper(_state, bonus, _buyBonus);
    } else if (bonus is SolveOneTurn) {
      return _SolveOneTurnDisplay(_state, bonus, _buyBonus);
    }
    return SizedBox.shrink();
  }
}

class _RevealCharDisplayWrapper extends StatelessWidget {
  final InventoryState _state;
  final RevealCharBonus _bonus;
  final Function(Bonus) _buy;

  _RevealCharDisplayWrapper(this._state, this._bonus, this._buy, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RevealCharBonusDisplay(_bonus, _number, false, () => _buy(_bonus));
  }

  int get _number {
    if (_bonus is RevealCharBonus1) {
      return _state.revealCharBonus1;
    } else if (_bonus is RevealCharBonus2) {
      return _state.revealCharBonus2;
    } else if (_bonus is RevealCharBonus5) {
      return _state.revealCharBonus5;
    } else if (_bonus is RevealCharBonus10) {
      return _state.revealCharBonus10;
    }
    return 0;
  }
}

class RevealCharBonusDisplay extends StatelessWidget {
  final int _number;
  final bool _disabled;
  final RevealCharBonus _bonus;
  final Function() _onPressed;

  RevealCharBonusDisplay(this._bonus, this._number, this._disabled, this._onPressed);

  double get _opacity {
    return _disabled ? 0.4 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacity,
      child: Container(
        width: 44,
        height: 40,
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
          key: Key("revealCharBonusBtn_${_bonus.power}"),
          onPressed: _onPressed,
          child: _buildBadge(),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    if (_number > 0) {
      return Badge(
        badgeContent: Text("$_number"),
        child: Image(
          fit: BoxFit.fitWidth,
          image: AssetImage("assets/images/wood_medal_${_bonus.power}.png"),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(6),
      child: Image(
        fit: BoxFit.fitWidth,
        image: AssetImage("assets/images/wood_medal_${_bonus.power}.png"),
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
