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
        ],
      ),
    );
  }

  String get _percentage {
    final value = _game.resolvedVersesCount / _game.model.versesCount;
    return "${(100 * value).round()} %";
  }
}
