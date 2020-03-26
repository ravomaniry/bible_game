import 'package:bible_game/app/db/extract_verse.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  test("Decompress", () async {
    final assetBundle = AssetBundleMock();
    final verses = "1 1 1 Tamin'ny voalohany\n1 1 2 Ny tany dia foana";
    when(assetBundle.loadString("assets/db/verses.txt")).thenAnswer((_) async => verses);
    expect(await loadVerses(assetBundle), [
      "1 1 1 Tamin'ny voalohany",
      "1 1 2 Ny tany dia foana",
    ]);
  });
}
