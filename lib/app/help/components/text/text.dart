import 'package:bible_game/app/help/components/text/models.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/widgets.dart';

class HelpText extends StatelessWidget {
  final TextContent _content;
  final AppColorTheme _theme;

  HelpText(this._content, this._theme, {key: Key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _Title(_content.title, _theme),
          for (var i = 0; i < _content.paragraphs.length; i++)
            _Paragraph(
              _content.paragraphs[i],
              i,
            )
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String _value;
  final AppColorTheme _theme;

  _Title(this._value, this._theme);

  @override
  Widget build(BuildContext context) {
    return Text(
      _value,
      style: TextStyle(
        color: _theme.accentLeft,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        decoration: TextDecoration.underline,
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final ParagraphContent _value;

  _Paragraph(this._value, int index) : super(key: Key(index.toString()));

  @override
  Widget build(BuildContext context) {
    return Text(_value.body);
  }
}
