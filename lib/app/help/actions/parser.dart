import 'dart:convert';

import 'package:bible_game/app/help/components/gallery/models.dart';
import 'package:bible_game/app/help/components/text/models.dart';

List<dynamic> parseHelp(String value) {
  final help = List();
  final Iterable list = json.decode(value);
  for (final item in list) {
    if (item is Map<String, dynamic>) {
      switch (item["type"]) {
        case "gallery":
          help.addAll(_parseGallery(item));
          break;
        case "text":
          help.addAll(_parseText(item));
          break;
      }
    }
  }
  return help;
}

List<GalleryContent> _parseGallery(value) {
  final images = List<HelpImageRef>();
  final inputImages = value["images"];
  if (inputImages is Iterable) {
    for (final item in inputImages) {
      final image = HelpImageRef(item["title"] ?? "", item["path"] ?? "");
      if (image.path != "") {
        images.add(image);
      }
    }
  }
  if (images.isNotEmpty) {
    return [GalleryContent(value["title"] ?? "", images)];
  }
  return [];
}

List<TextContent> _parseText(value) {
  final paragraphs = List<ParagraphContent>();
  final inputParagraphs = value["paragraphs"];
  if (inputParagraphs is Iterable) {
    for (final item in inputParagraphs) {
      final subtitle = item["subtitile"] ?? "";
      final body = item["body"] ?? "";
      if (subtitle != "" || body != "") {
        paragraphs.add(ParagraphContent(subtitle, body));
      }
    }
  }
  if (paragraphs.isNotEmpty) {
    return [TextContent(value["title"] ?? "", paragraphs)];
  }
  return [];
}
