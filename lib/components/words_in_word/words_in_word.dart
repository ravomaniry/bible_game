import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WordsInWord extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key("wordsInWord"),
      appBar: AppBar(
        title: Text("Words in word"),
      ),
      body: Center(
        child: Text("Hello words in word!"),
      ),
    );
  }
}
