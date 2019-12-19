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
            Icons.view_carousel,
            "goToExplorer",
            _viewModel.goToExplorer,
            _viewModel.theme.accentLeft,
          ),
        ],
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final IconData _iconData;
  final String _key;
  final Function() _onPressed;
  final Color _color;

  HomeButton(this._iconData, this._key, this._onPressed, this._color);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: Key(_key),
      onPressed: _onPressed,
      icon: Icon(_iconData),
      color: _color,
      iconSize: 40,
    );
  }
}
