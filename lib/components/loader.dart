import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key("loader"),
      appBar: AppBar(
        title: Text("Loading..."),
      ),
      body: Center(child: Text("Querying database ...")),
    );
  }
}
