import 'package:bible_game/app/help/models.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/widgets.dart';

class HelpGalleryView extends StatelessWidget {
  final HelpGallery _value;
  final AppColorTheme _theme;

  HelpGalleryView(this._value, this._theme) : super(key: _value.key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Title(this._value.title, _theme),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [for (final image in _value.images) _ImageItem(image)],
          ),
        ),
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
    return Text(
      _value,
      style: TextStyle(
        color: _theme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ImageItem extends StatelessWidget {
  final HelpGalleryImage image;

  _ImageItem(this.image) : super(key: image.key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 240),
            child: Image(
              image: AssetImage(image.path),
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
        Text(image.title),
      ],
    );
  }
}
