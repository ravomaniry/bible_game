import 'package:bible_game/components/game/games_list/list_item.dart';
import 'package:bible_game/redux/game/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class GamesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: GameViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, GameViewModel _vieModel) {
    return Expanded(
      child: _GameListContainer(
        _vieModel,
        child: ListView(
          children:
              _vieModel.state.list.map((game) => GameListItem(game, _vieModel.selectHandler, _vieModel.theme)).toList(),
        ),
      ),
    );
  }
}

class _GameListContainer extends StatelessWidget {
  final GameViewModel _viewModel;
  final Widget child;

  _GameListContainer(this._viewModel, {@required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 6),
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: _viewModel.theme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
