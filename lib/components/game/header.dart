import 'package:bible_game/redux/game/view_model.dart';
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
          _GoToEditorBtn(
            _viewModel.goToEditor,
            _viewModel.theme.primaryDark,
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

class _GoToEditorBtn extends StatelessWidget {
  final Function() _onPressed;
  final Color _color;

  _GoToEditorBtn(this._onPressed, this._color);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        onPressed: _onPressed,
        key: Key("goToEditor"),
        child: Icon(
          Icons.add_circle_outline,
          color: _color,
          size: 48,
        ),
      ),
    );
  }
}
