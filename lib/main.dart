import 'package:bible_game/components/dialogs/quit_single_game.dart';
import 'package:bible_game/components/router.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/db/actions.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/redux/router/reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final _store = Store<AppState>(
    mainReducer,
    initialState: AppState.initialState(rootBundle),
    middleware: [thunkMiddleware],
  );
  runApp(BibleGame(_store));
}

class BibleGame extends StatefulWidget {
  final Store<AppState> _store;

  BibleGame(this._store);

  @override
  State<StatefulWidget> createState() => _BibleGameState(_store);
}

class _BibleGameState extends State<BibleGame> {
  final Store<AppState> _store;

  _BibleGameState(this._store);

  @override
  void initState() {
    super.initState();
    handleBackBtnPress(_store);
    _store.dispatch(initDb);
  }

  @override
  void dispose() {
    super.dispose();
    disposeBackBtnHandler();
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: _store,
      child: MaterialApp(
        title: 'Flutter Calculator',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Stack(
          children: <Widget>[
            Router(),
            QuitSingleGameDialog(),
          ],
        ),
      ),
    );
  }
}
