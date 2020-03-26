import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class HelpSection {
  final String title;
  final List<dynamic> contents;
  final Key key = UniqueKey();

  HelpSection(this.title, this.contents);

  @override
  int get hashCode => hashValues(title, contents.hashCode);

  @override
  bool operator ==(other) {
    return other is HelpSection && other.title == title && listEquals(other.contents, contents);
  }

  @override
  String toString() => "{title: '$title', paragraphs: '$contents'}";
}

class HelpParagraph {
  final String subtitle;
  final String body;
  final Key key = UniqueKey();

  HelpParagraph(this.subtitle, this.body);

  @override
  int get hashCode => hashValues(subtitle, body);

  @override
  bool operator ==(other) {
    return other is HelpParagraph && other.subtitle == subtitle && other.body == body;
  }

  @override
  String toString() => "{subtitle: '$subtitle', body: '$body'}";
}

class HelpGallery {
  final String title;
  final List<HelpGalleryImage> images;
  final Key key = UniqueKey();

  HelpGallery(this.title, this.images);

  @override
  int get hashCode => hashValues(title, images);

  @override
  bool operator ==(other) {
    return other is HelpGallery && other.title == title && listEquals(other.images, images);
  }
}

class HelpGalleryImage {
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
}
