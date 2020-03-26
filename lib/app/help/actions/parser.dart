import 'dart:convert';

import 'package:bible_game/app/help/models.dart';

List<HelpUiItem> parseHelp(String value) {
  final help = List<HelpUiItem>();
  final Iterable list = json.decode(value);
  for (final item in list) {
    if (item is Map<String, dynamic>) {
      final parsed = _parseItem(item);
      if (parsed != null) {
        help.add(parsed);
      }
    }
  }
  return help;
}

HelpUiItem _parseItem(json) {
  if (json is Map<String, dynamic>) {
    switch (json["type"]) {
      case "section":
        return _parseSection(json);
      case "paragraph":
        return _parseParagraph(json);
      case "gallery":
        return _parseGallery(json);
    }
  }
  return null;
}

HelpSection _parseSection(json) {
  final title = _getTitle(json);
  final Iterable contents = json["contents"] is Iterable ? json["contents"] : [];
  final parsedContents = contents.map(_parseItem).where((x) => x != null).toList();
  return HelpSection(title, parsedContents);
}

HelpParagraph _parseParagraph(json) {
  final title = _getTitle(json);
  final text = _getString(json, "text");
  return title.isNotEmpty || text.isNotEmpty ? HelpParagraph(title, text) : null;
}

HelpGallery _parseGallery(json) {
  final title = _getTitle(json);
  final images = _parseImages(json["images"]);
  return title.isNotEmpty || images.isNotEmpty ? HelpGallery(title, images) : null;
}

List<HelpGalleryImage> _parseImages(json) {
  final images = List<HelpGalleryImage>();
  if (json is Iterable) {
    for (final item in json) {
      if (item is Map<String, dynamic>) {
        final title = _getTitle(item);
        final path = _getString(item, "path");
        if (title.isNotEmpty && path.isNotEmpty) {
          images.add(HelpGalleryImage(title, path));
        }
      }
    }
  }
  return images;
}

String _getTitle(json) {
  return _getString(json, "title");
}

String _getString(json, String key) {
  final title = json[key];
  return title is String ? title : "";
}
