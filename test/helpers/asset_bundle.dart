import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';

class AssetBundleMock extends Mock implements AssetBundle {
  AssetBundleMock();

  factory AssetBundleMock.withDefaultValue() {
    final assetBundle = AssetBundleMock();
    final booksKey = "assets/db/new_testament_books.json";
    final versesKey = "assets/db/new_testament_verses.json";

    when(assetBundle.loadString(booksKey)).thenAnswer((_) async {
      return json.encode([
        Map()..putIfAbsent("id", () => 1)..putIfAbsent("name", () => "Genesisy")..putIfAbsent("chapters", () => 10),
      ]);
    });

    when(assetBundle.loadString(versesKey)).thenAnswer((_) async {
      return json.encode([
        Map()
          ..putIfAbsent("book", () => 1)
          ..putIfAbsent("chapter", () => 2)
          ..putIfAbsent("verse", () => 3)
          ..putIfAbsent("text", () => "Ny filazana ny razan'i Jesosy Kristy"),
      ]);
    });
    return assetBundle;
  }
}
