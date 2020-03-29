import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/congrat/congratulation_view_model.dart';
import 'package:bible_game/app/game_editor/components/editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Congratulations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CongratulationsViewModel>(
      converter: CongratulationsViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, CongratulationsViewModel _viewModel) {
    return Scaffold(
      body: Container(
        key: Key("congratulations"),
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(_viewModel.texts.congratulation),
            OkButton(
              btnKey: "congratulationsOkBtn",
              onClick: _viewModel.closeHandler,
              theme: _viewModel.theme,
            ),
          ],
        ),
      ),
    );
  }
}
