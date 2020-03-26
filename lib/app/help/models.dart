import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class HelpUiItem {
  final Key key;

  HelpUiItem(this.key);

  @override
  int get hashCode => hashValues(key, "");

  @override
  bool operator ==(other) => other is HelpUiItem && other.key == key;
}

class HelpSection implements HelpUiItem {
  final String title;
  final List<HelpUiItem> contents;
  final Key key = UniqueKey();

  HelpSection(this.title, this.contents);

  @override
  int get hashCode => hashValues(title, contents.hashCode);

  @override
  bool operator ==(other) {
    return other is HelpSection && other.title == title && listEquals(other.contents, contents);
  }

  @override
  String toString() => "{title: '$title', contents: '$contents'}";
}

class HelpParagraph implements HelpUiItem {
  final String title;
  final String text;
  final Key key = UniqueKey();

  HelpParagraph(this.title, this.text);

  @override
  int get hashCode => hashValues(title, text);

  @override
  bool operator ==(other) {
    return other is HelpParagraph && other.title == title && other.text == text;
  }

  @override
  String toString() => "{title: '$title', text: '$text'}";
}

class HelpGallery implements HelpUiItem {
  final String title;
  final List<HelpGalleryImage> images;
  final Key key = UniqueKey();

  HelpGallery(this.title, this.images);

  @override
  int get hashCode => hashValues(title, images.hashCode);

  @override
  bool operator ==(other) {
    return other is HelpGallery && other.title == title && listEquals(other.images, images);
  }

  @override
  String toString() => "{title: '$title', images: '$images'}";
}

class HelpGalleryImage implements HelpUiItem {
  final String title;
  final String path;
  final Key key = UniqueKey();

  HelpGalleryImage(this.title, this.path);

  @override
  int get hashCode => hashValues(title, path);

  @override
  bool operator ==(other) {
    return other is HelpGalleryImage && other.title == title && other.path == path;
  }

  @override
  String toString() {
    return "{title: '$title', path: '$path'}";
  }
}
