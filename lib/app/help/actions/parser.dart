import 'dart:convert';

import 'package:bible_game/app/help/components/models.dart';

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

List<HelpGallery> _parseGallery(value) {
  final images = List<HelpGalleryImage>();
  final inputImages = value["images"];
  if (inputImages is Iterable) {
    for (final item in inputImages) {
      final image = HelpGalleryImage(item["title"] ?? "", item["path"] ?? "");
      if (image.path != "") {
        images.add(image);
      }
    }
  }
  if (images.isNotEmpty) {
    return [HelpGallery(value["title"].toString() ?? "", images)];
  }
  return [];
}

List<HelpSection> _parseText(value) {
  final paragraphs = List<HelpParagraph>();
  final inputParagraphs = value["paragraphs"];
  if (inputParagraphs is Iterable) {
    for (final item in inputParagraphs) {
      final subtitle = item["subtitle"] ?? "";
      final body = item["body"] ?? "";
      if (subtitle != "" || body != "") {
        paragraphs.add(HelpParagraph("$subtitle", "$body"));
      }
    }
  }
  if (paragraphs.isNotEmpty) {
    return [HelpSection(value["title"] ?? "", paragraphs)];
  }
  return [];
}
