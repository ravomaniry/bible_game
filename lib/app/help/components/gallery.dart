import 'package:bible_game/app/help/components/models.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/widgets.dart';

class Gallery extends StatelessWidget {
  final HelpGallery _content;
  final AppColorTheme _theme;

  Gallery(this._content, this._theme, {key: Key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Title(this._content.title, _theme),
            for (final image in _content.images) _ImageItem(image)
          ],
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(
          image: AssetImage(image.path),
          fit: BoxFit.fitHeight,
        ),
        Text(image.title),
      ],
    );
  }
}
