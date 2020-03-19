import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ParagraphContent with EquatableMixin {
  final String subtitle;
  final String body;
  final Key key = UniqueKey();

  ParagraphContent(this.subtitle, this.body);

  @override
  List<Object> get props => [subtitle, body];
}

class TextContent with EquatableMixin {
  final String title;
  final List<ParagraphContent> paragraphs;
  final Key key = UniqueKey();

  TextContent(this.title, this.paragraphs);

  @override
  List<Object> get props => [title, paragraphs];
}
