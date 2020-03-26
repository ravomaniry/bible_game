import 'dart:math';

import 'package:bible_game/utils/retry.dart';
import 'package:flutter/services.dart';

Future<List<String>> loadVerses(AssetBundle assetBundle) async {
  final rawSequences = await retry(() => assetBundle.loadString("assets/db/verse_seqs.txt"));
  final sequences = extractSequences(rawSequences);
  final body = await retry(() => assetBundle.load("assets/db/verses.ddlzip"));
  return _extractLines(sequences, body);
}

List<String> _extractLines(List<String> sequences, ByteData body) {
  final lines = List<String>();
  final charSize = _getCharSize(sequences.length);
  var bits = "";
  var line = "";

  for (var i = 0, max = body.lengthInBytes; i < max; i++) {
    final bin = _addZeroesBefore(body.getUint8(i).toRadixString(2), 8);
    bits += bin;
    while (bits.length > charSize) {
      final index = int.parse(bits.substring(0, charSize), radix: 2);
      if (index == 0) {
        if (line.isNotEmpty) {
          lines.add(line);
          line = "";
        }
      } else {
        line += sequences[index - 1];
      }
      bits = bits.substring(charSize);
    }
  }
  if (line.isNotEmpty) {
    lines.add(line);
  }
  return lines;
}

List<String> extractSequences(String rawValue) {
  return rawValue.split("_").where((c) => c.isNotEmpty).toList();
}

int _getCharSize(int charsCount) {
  var size = 0;
  while (pow(2, size) <= charsCount) {
    size++;
  }
  return size;
}

String _addZeroesBefore(String value, charSize) {
  while (value.length < charSize) {
    value = '0' + value;
  }
  return value;
}
