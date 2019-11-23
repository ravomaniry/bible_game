import 'package:flutter/services.dart';
import 'package:redux/redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:bible_game/redux/reducers.dart';
import 'package:bible_game/model/calculator_state.dart';
import 'package:bible_game/components/calculator/calculator.dart';

void main() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Store<AppState> store = Store<AppState>(
    mainReducer,
    initialState: AppState(output: "", operator: "", mode: "a", b: 0, a: 0),
  );

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Flutter Calculator',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Calculator(),
      ),
    );
  }
}
