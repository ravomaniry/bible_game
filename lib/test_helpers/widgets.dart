import 'package:bible_game/app/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class Testable extends StatelessWidget {
  final Widget _child;

  Testable(this._child);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _child,
    );
  }
}

class TestableWithStore extends StatelessWidget {
  final Widget child;
  final Store<AppState> store;

  TestableWithStore({
    @required this.child,
    @required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StoreProvider<AppState>(
        store: store,
        child: child,
      ),
    );
  }
}
