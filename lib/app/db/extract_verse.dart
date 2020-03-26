import 'package:bible_game/utils/retry.dart';
import 'package:flutter/services.dart';

Future<List<String>> loadVerses(AssetBundle assetBundle) async {
  final rawVerses = await retry(() => assetBundle.loadString("assets/db/verses.txt"));
  return await _extractLines(rawVerses);
}

Future<List<String>> _extractLines(String rawVerses) async {
  final lines = List<String>();
  var line = "";
  for (var i = 0, length = rawVerses.length; i < length; i++) {
    if (rawVerses[i] == "\n") {
      if (line.isNotEmpty) {
        lines.add(line);
        line = "";
      }
    } else {
      line += rawVerses[i];
    }
    if (i % 8000 == 0) {
      await Future.delayed(Duration(milliseconds: 5));
    }
  }
  if (line.isNotEmpty) {
    lines.add(line);
  }
  return lines;
}
