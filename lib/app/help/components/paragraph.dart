import 'package:bible_game/app/help/models.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/widgets.dart';

class HelpParagraphView extends StatelessWidget {
  final HelpParagraph _value;
  final AppColorTheme _theme;

  HelpParagraphView(this._value, this._theme) : super(key: _value.key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title(_value.title, _theme, _value.key),
          _Text(_value.text),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String _value;
  final AppColorTheme _theme;
  final Key key;

  _Title(this._value, this._theme, this.key) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      _value,
      style: TextStyle(
        fontSize: 16,
        color: _theme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _Text extends StatelessWidget {
  final String _value;

  _Text(this._value);

  @override
  Widget build(BuildContext context) {
    return Text(_value);
  }
}
