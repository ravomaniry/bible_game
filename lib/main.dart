import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/components/router.dart';
import 'package:flutter/services.dart';
import 'package:redux/redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:bible_game/redux/main_reducer.dart';

void main() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(BibleGame());
}

class BibleGame extends StatelessWidget {
  final Store<AppState> store = Store<AppState>(
    mainReducer,
    initialState: AppState.initialState(),
  );

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Flutter Calculator',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Router(),
      ),
    );
  }
}
