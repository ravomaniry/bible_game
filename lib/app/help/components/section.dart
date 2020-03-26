import 'package:bible_game/app/help/models.dart';
import 'package:bible_game/app/help/components/router.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/widgets.dart';

class HelpSectionView extends StatelessWidget {
  final HelpSection _value;
  final AppColorTheme _theme;

  HelpSectionView(this._value, this._theme);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Title(_value.title, _theme),
        _Body(_value.contents, _theme),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  final String _value;
  final AppColorTheme _theme;

  _Title(this._value, this._theme);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _value,
        style: TextStyle(
          color: _theme.accentLeft,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final List<HelpUiItem> _value;
  final AppColorTheme _theme;

  _Body(this._value, this._theme);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [for (final item in _value) helpComponentRouter(item, _theme)],
      ),
    );
  }
}
