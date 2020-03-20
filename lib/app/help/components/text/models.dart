import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ParagraphContent {
  final String subtitle;
  final String body;
  final Key key = UniqueKey();

  ParagraphContent(this.subtitle, this.body);

  @override
  int get hashCode => hashValues(subtitle, body);

  @override
  bool operator ==(other) {
    return other is ParagraphContent && other.subtitle == subtitle && other.body == body;
  }

  @override
  String toString() => "{subtitle: '$subtitle', body: '$body'}";
}

class TextContent {
  final String title;
  final List<ParagraphContent> paragraphs;
  final Key key = UniqueKey();

  TextContent(this.title, this.paragraphs);

  @override
  int get hashCode => hashValues(title, paragraphs.hashCode);

  @override
  bool operator ==(other) {
    return other is TextContent && other.title == title && listEquals(other.paragraphs, paragraphs);
  }

  @override
  String toString() => "{title: '$title', paragraphs: '$paragraphs'}";
}
