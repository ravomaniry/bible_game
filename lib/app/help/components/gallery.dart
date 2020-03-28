import 'package:bible_game/app/help/components/paragraph.dart';
import 'package:bible_game/app/help/models.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class HelpGalleryView extends StatelessWidget {
  final HelpGallery _value;
  final AppColorTheme _theme;

  HelpGalleryView(this._value, this._theme) : super(key: _value.key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParagraphTitle(this._value.title, _theme, this.key),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [for (final image in _value.images) _ImageItem(image, _theme)],
          ),
        ),
      ],
    );
  }
}

class _ImageItem extends StatelessWidget {
  final HelpGalleryImage image;
  final AppColorTheme _theme;

  _ImageItem(this.image, this._theme) : super(key: image.key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _theme.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.all(1),
      child: Column(
        children: [
          Container(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image(
                image: AssetImage(image.path),
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          _ImageTitle(image.title, _theme),
        ],
      ),
    );
  }
}

class _ImageTitle extends StatelessWidget {
  final String _value;
  final AppColorTheme _theme;

  _ImageTitle(this._value, this._theme);

  @override
  Widget build(BuildContext context) {
    return Text(
      _value,
      style: TextStyle(
        color: _theme.neutral,
        fontSize: 12,
      ),
    );
  }
}
