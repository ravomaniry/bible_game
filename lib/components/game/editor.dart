import 'package:bible_game/redux/game/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class GameEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: GameViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, GameViewModel viewModel) {
    if (viewModel.state.dialogIsOpen) {
      return Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(180, 0, 0, 0),
        ),
        child: Dialog(
          child: Container(
            child: Column(
              children: [
                Text("Dialog goes here..."),
                RaisedButton(
                  key: Key("closeEditorDialog"),
                  onPressed: viewModel.toggleDialog,
                  child: Text("Ok"),
                )
              ],
            ),
          ),
        ),
      );
    }
    return Positioned(
      right: 20,
      bottom: 20,
      child: FloatingActionButton(
        key: Key("showEditorDialog"),
        child: Text("+"),
        onPressed: viewModel.toggleDialog,
      ),
    );
  }
}
