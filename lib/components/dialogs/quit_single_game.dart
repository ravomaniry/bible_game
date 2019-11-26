import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/quit_single_game_dialog/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class QuitSingleGameDialog extends StatelessWidget {
  Widget _builder(BuildContext context, QuitSingleGameViewModel viewModel) {
    if (viewModel.isOpen) {
      return Container(
        key: Key("confirmQuitSingleGame"),
        child: Center(
          child: Column(
            children: <Widget>[
              Text("Do you really want to quit"),
              Row(
                children: <Widget>[
                  RaisedButton(
                    key: Key("dialogYesBtn"),
                    child: Text("Yes"),
                    onPressed: viewModel.confirmHandler,
                  ),
                  RaisedButton(
                    key: Key("dialogNoBtn"),
                    child: Text("NO"),
                    onPressed: viewModel.cancelHandler,
                  )
                ],
              )
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, QuitSingleGameViewModel>(
      converter: QuitSingleGameViewModel.converter,
      builder: _builder,
    );
  }
}
