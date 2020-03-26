import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';

class AssetBundleMock extends Mock implements AssetBundle {
  AssetBundleMock();

  factory AssetBundleMock.withDefaultValue() {
    final assetBundle = AssetBundleMock();
    final booksKey = "assets/db/books.json";
    final verseSequencesKey = "assets/db/verse_seqs.txt";
    final versesKey = "assets/db/verses.ddlzip";

    when(assetBundle.loadString(booksKey)).thenAnswer((_) async {
      return json.encode([
        Map()
          ..putIfAbsent("id", () => 1)
          ..putIfAbsent("name", () => "Genesisy")
          ..putIfAbsent("chapters", () => 10),
      ]);
    });

    when(assetBundle.loadString(verseSequencesKey)).thenAnswer(
      (_) async => ["Ny", "filaz", "ana", "ny", "razan'i", "Jesosy", "Kristy", " ", "1"].join("_"),
    );
    when(assetBundle.load(versesKey)).thenAnswer((_) async {
      final bins = [
        "10011000", // "1 "
        "10011000", // "1 "
        "10011000", // "1 "
        "00011000", // "Ny "
        "00100011", // "filaz+ana"
        "10000100", // " ny"
        "10000101", // " razan'i"
        "10000110", // " Jesosy"
        "10000111", // " Kristy"
        "00000000", // 2 * separators
      ];
      final data = ByteData(bins.length);
      for (var i = 0; i < bins.length; i++) {
        data.setInt8(i, int.parse(bins[i], radix: 2));
      }
      return data;
    });
    when(assetBundle.loadString("assets/help.json")).thenAnswer((_) async => "[]");
    return assetBundle;
  }
}
