import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/confirm_quit_dialog/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
      return GestureDetector(
        onTap: viewModel.cancelHandler,
        child: Container(
          color: Color.fromARGB(190, 0, 0, 0),
          child: GestureDetector(
            onTap: () {},
            child: AlertDialog(
              key: Key("confirmQuitSingleGame"),
              elevation: 10,
              content: Text(
                viewModel.texts.confirmQuit,
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                FlatButton(
                  textColor: Colors.deepOrange,
                  key: Key("dialogYesBtn"),
                  child: Text(viewModel.texts.yes.toUpperCase()),
                  onPressed: viewModel.confirmHandler,
                ),
                FlatButton(
                  textColor: Colors.blue,
                  key: Key("dialogNoBtn"),
                  child: Text(viewModel.texts.no.toUpperCase()),
                  onPressed: viewModel.cancelHandler,
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
