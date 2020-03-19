import 'package:bible_game/app/game/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeHeader extends StatelessWidget {
  final GameViewModel _viewModel;

  HomeHeader(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _HomeButton(
            "goToExplorer",
            _viewModel.goToExplorer,
            _viewModel.theme.primaryDark,
          ),
          _GoToBtn(
            stingKey: "goToEdiror",
            color: _viewModel.theme.primaryDark,
            icon: Icons.add_circle_outline,
            onPressed: _viewModel.goToEditor,
          ),
          _GoToBtn(
            stingKey: "goToHelp",
            color: _viewModel.theme.primaryDark,
            icon: Icons.help_outline,
            onPressed: _viewModel.goToHelp,
          ),
        ],
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final String _key;
  final Function() _onPressed;
  final Color _color;

  _HomeButton(this._key, this._onPressed, this._color);

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

class _GoToBtn extends StatelessWidget {
  final Function() onPressed;
  final Color color;
  final IconData icon;
  final String stingKey;

  _GoToBtn({
    @required this.icon,
    @required this.color,
    @required this.onPressed,
    @required this.stingKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        onPressed: onPressed,
        key: Key(stingKey),
        child: Icon(
          icon,
          color: color,
          size: 48,
        ),
      ),
    );
  }
}
