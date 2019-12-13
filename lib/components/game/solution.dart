import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/game/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Solution extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, GameViewModel>(
      converter: GameViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, GameViewModel viewModel) {
    return _SolutionBuilder(viewModel);
  }
}

class _SolutionBuilder extends StatelessWidget {
  final GameViewModel _viewModel;

  _SolutionBuilder(this._viewModel);

  @override
  Widget build(BuildContext context) {
    final verse = _viewModel.state.verse;

    return Container(
      key: Key("solutionScreen"),
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fitWidth,
          image: AssetImage("assets/images/forest.jpg"),
        ),
      ),
      child: Column(
        children: <Widget>[
          Expanded(child: Divider()),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(200, 255, 255, 255),
            ),
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  verse.text,
                  style: const TextStyle(fontSize: 16),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${verse.book} ${verse.chapter}: ${verse.verse}",
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                RaisedButton(
                  key: Key("nextButton"),
                  onPressed: _viewModel.nextHandler,
                  child: Text("Next"),
                )
              ],
            ),
          ),
          Expanded(child: Divider()),
        ],
      ),
    );
  }
}
