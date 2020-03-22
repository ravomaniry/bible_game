import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';

class AssetBundleMock extends Mock implements AssetBundle {
  AssetBundleMock();

  factory AssetBundleMock.withDefaultValue() {
    final assetBundle = AssetBundleMock();
    final booksKey = "assets/db/books.json";
    final versesKey = "assets/db/verses.txt";

    when(assetBundle.loadString(booksKey)).thenAnswer((_) async {
      return json.encode([
        Map()
          ..putIfAbsent("id", () => 1)
          ..putIfAbsent("name", () => "Genesisy")
          ..putIfAbsent("chapters", () => 10),
      ]);
    });

    when(assetBundle.loadString(versesKey)).thenAnswer((_) async {
      return "filazana Jesosy Kristy\n"
          "1 2 3 Ny _0 ny razan'i _1 _2";
    });
    when(assetBundle.loadString("assets/help.json")).thenAnswer(
      (_) async => "[]",
    );
    return assetBundle;
  }
}
