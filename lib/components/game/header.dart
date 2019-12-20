import 'package:bible_game/redux/game/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeHeader extends StatelessWidget {
  final GameViewModel _viewModel;

  HomeHeader(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Column(
        children: [
          HomeButton(
            "goToExplorer",
            _viewModel.goToExplorer,
            _viewModel.theme.primaryDark,
          ),
        ],
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final String _key;
  final Function() _onPressed;
  final Color _color;

  HomeButton(this._key, this._onPressed, this._color);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      key: Key(_key),
      onPressed: _onPressed,
      child: Image(
        color: _color,
        image: AssetImage("assets/images/bible.png"),
      ),
    );
  }
}
