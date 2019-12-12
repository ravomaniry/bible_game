import 'package:bible_game/models/game.dart';
import 'package:bible_game/redux/games/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class GamesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: GamesListViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, GamesListViewModel _vieModel) {
    return Expanded(
      child: ListView(
        children: _vieModel.state.list.map((game) => GameListItem(game)).toList(),
      ),
    );
  }
}

class GameListItem extends StatelessWidget {
  final GameModelWrapper _game;

  GameListItem(this._game);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(200, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1,
          color: Color.fromARGB(75, 0, 0, 0),
        ),
      ),
      margin: EdgeInsets.only(left: 10, right: 10, top: 2),
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_game.model.name),
              Text("${_game.inventory.money} Ar."),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  backgroundColor: Color.fromARGB(255, 140, 140, 140),
                  value: _game.resolvedVersesCount / _game.model.versesCount,
                ),
              ),
              SizedBox(width: 10),
              Text(_percentage),
            ],
          ),
          Bonuses(_game),
        ],
      ),
    );
  }

  String get _percentage {
    final value = _game.resolvedVersesCount / _game.model.versesCount;
    return "${(100 * value).round()} %";
  }
}

class Bonuses extends StatelessWidget {
  final GameModelWrapper _game;

  Bonuses(this._game);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BonusItem("assets/images/wood_medal_1.png", _game.inventory.revealCharBonus1),
        BonusItem("assets/images/wood_medal_2.png", _game.inventory.revealCharBonus2),
        BonusItem("assets/images/wood_medal_5.png", _game.inventory.revealCharBonus5),
        BonusItem("assets/images/wood_medal_10.png", _game.inventory.revealCharBonus10),
      ],
    );
  }
}

class BonusItem extends StatelessWidget {
  final String _imagePath;
  final int _number;

  BonusItem(this._imagePath, this._number);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 20,
      margin: EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 4),
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
            child: Text("$_number"),
          )
        ],
      ),
    );
  }
}
