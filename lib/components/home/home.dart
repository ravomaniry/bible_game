import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/home/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, HomeViewModel>(
      key: Key("home"),
      builder: _builder,
      converter: HomeViewModel.converter,
    );
  }

  Widget _builder(BuildContext context, HomeViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bible game"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: Text("Home")),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    key: Key("goToCalculatorBtn"),
                    child: Text("Calculator"),
                    onPressed: viewModel.goToCalculator,
                  ),
                ),
                Expanded(
                  child: RaisedButton(
                    key: Key("goToWordsInWordBtn"),
                    child: Text("Words in Word"),
                    onPressed: viewModel.goToWordsInWord,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
