import 'dart:typed_data';

import 'package:bible_game/app/db/extract_verse.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  test("Decompress", () async {
    final assetBundle = AssetBundleMock();
    final bits = [
      "01011010", // a a b b
      "11001010", // c 0 b b
      "01011100", // a a c 0
      "11110101", // c c a a
      "10001111", // b 0 c c
      "10100100", // b b a 0
    ];
    final body = ByteData(6);
    for (var i = 0; i < bits.length; i++) {
      body..setInt8(i, int.parse(bits[i], radix: 2));
    }
    // Mocks
    when(assetBundle.loadString(any)).thenAnswer((_) async => "a_b_c_");
    when(assetBundle.load(any)).thenAnswer((_) async => body);
    expect(await loadVerses(assetBundle), ["aabbc", "bbaac", "ccaab", "ccbba"]);
  });
}
