import 'dart:math';

import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/models/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GameListItem extends StatelessWidget {
  final GameModelWrapper _game;
  final Function(GameModelWrapper) _selectHandler;
  final AppColorTheme _theme;

  GameListItem(this._game, this._selectHandler, this._theme);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key("game_${_game.model.id}"),
      onTap: () => _selectHandler(_game),
      child: _GameListItemContainer(
        theme: _theme,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _GameName(_game.model.name, _theme),
                _Money(_game.inventory.money, _theme),
              ],
            ),
            _Progress(_game, _theme),
            _Bonuses(_game),
          ],
        ),
      ),
    );
  }
}

class _GameListItemContainer extends StatelessWidget {
  final AppColorTheme theme;
  final Widget child;

  _GameListItemContainer({@required this.theme, @required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.neutral.withAlpha(220),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: theme.primaryDark,
            offset: Offset(2, 2),
            blurRadius: 2,
          ),
        ],
      ),
      margin: EdgeInsets.only(left: 10, right: 10, top: 6),
      padding: EdgeInsets.all(10),
      child: child,
    );
  }
}

class _GameName extends StatelessWidget {
  final AppColorTheme _theme;
  final String _name;

  _GameName(this._name, this._theme);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - 100,
      ),
      child: Text(
        _name,
        style: TextStyle(
          color: _theme.primaryDark,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Money extends StatelessWidget {
  final int _value;
  final AppColorTheme _theme;

  _Money(this._value, this._theme);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 3),
      decoration: BoxDecoration(
        color: _theme.primaryDark,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "$_value Ar",
        style: TextStyle(color: _theme.neutral),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final GameModelWrapper _game;
  final AppColorTheme _theme;

  _Progress(this._game, this._theme);

  String get _percentage {
    final value = min(1, _game.resolvedVersesCount / _game.model.versesCount);
    return "${(100 * value).round()} %";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            backgroundColor: Color.fromARGB(255, 150, 150, 150),
            valueColor: AlwaysStoppedAnimation<Color>(_theme.accentLeft),
            value: _game.resolvedVersesCount / _game.model.versesCount,
          ),
        ),
        SizedBox(width: 10),
        Text(
          _percentage,
          style: TextStyle(
            color: _theme.accentLeft,
          ),
        ),
      ],
    );
  }
}

class _Bonuses extends StatelessWidget {
  final GameModelWrapper _game;

  _Bonuses(this._game);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BonusItem("assets/images/wood_medal_1.png", _game.inventory.revealCharBonus1),
        _BonusItem("assets/images/wood_medal_2.png", _game.inventory.revealCharBonus2),
        _BonusItem("assets/images/wood_medal_5.png", _game.inventory.revealCharBonus5),
        _BonusItem("assets/images/wood_medal_10.png", _game.inventory.revealCharBonus10),
      ],
    );
  }
}

class _BonusItem extends StatelessWidget {
  final String _imagePath;
  final int _number;

  _BonusItem(this._imagePath, this._number);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 20,
      margin: EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 2),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Image(
                fit: BoxFit.fitHeight,
                image: AssetImage(_imagePath),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "$_number",
              style: const TextStyle(fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}
