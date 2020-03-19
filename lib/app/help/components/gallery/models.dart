import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class HelpImageRef {
  final String title;
  final String path;
  final Key key = UniqueKey();

  HelpImageRef(this.title, this.path);

  @override
  int get hashCode => hashValues(title, path);

  @override
  bool operator ==(other) {
    return other is HelpImageRef && other.title == title && other.path == path;
  }
}

class GalleryContent {
  final String title;
  final List<HelpImageRef> images;
  final Key key = UniqueKey();

  GalleryContent(this.title, this.images);

  @override
  int get hashCode => hashValues(title, images);

  @override
  bool operator ==(other) {
    return other is GalleryContent && other.title == title && listEquals(other.images, images);
  }
}
