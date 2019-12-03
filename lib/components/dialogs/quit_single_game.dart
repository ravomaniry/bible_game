import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/quit_single_game_dialog/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class QuitSingleGameDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, QuitSingleGameViewModel>(
      converter: QuitSingleGameViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, QuitSingleGameViewModel viewModel) {
    if (viewModel.isOpen) {
      return Container(
        color: Color.fromARGB(190, 0, 0, 0),
        child: Dialog(
          key: Key("confirmQuitSingleGame"),
          elevation: 10,
          child: Container(
            height: MediaQuery.of(context).size.height / 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Do you really want to quit"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      textColor: Colors.deepOrange,
                      key: Key("dialogYesBtn"),
                      child: Text("Yes"),
                      onPressed: viewModel.confirmHandler,
                    ),
                    FlatButton(
                      textColor: Colors.blue,
                      key: Key("dialogNoBtn"),
                      child: Text("NO"),
                      onPressed: viewModel.cancelHandler,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
