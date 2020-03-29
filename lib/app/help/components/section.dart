import 'package:bible_game/app/help/components/router.dart';
import 'package:bible_game/app/help/models.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HelpSectionView extends StatelessWidget {
  final HelpSection _value;
  final AppColorTheme _theme;

  HelpSectionView(this._value, this._theme);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5),
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title(_value.title, _theme),
          _Body(_value.contents, _theme),
        ],
      ),
    );
  }
}

final _shadowColor = Colors.grey;

class _Title extends StatelessWidget {
  final String _value;
  final AppColorTheme _theme;

  _Title(this._value, this._theme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        _value,
        style: TextStyle(
          fontSize: 24,
          color: _theme.accentLeft,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: _shadowColor,
              offset: Offset(2, 1),
              blurRadius: 1,
            ),
          ],
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
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final item in _value) helpComponentRouter(item, _theme)],
      ),
    );
  }
}
