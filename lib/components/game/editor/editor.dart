import 'package:bible_game/components/game/editor/add_button.dart';
import 'package:bible_game/components/game/editor/dialog.dart';
import 'package:bible_game/redux/game/editor_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class GameEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: EditorViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, EditorViewModel viewModel) {
    if (viewModel.state.dialogIsOpen) {
      return EditorDialog(viewModel);
    }
    return AddButton(
      theme: viewModel.theme,
      onPressed: viewModel.toggleDialog,
    );
  }
}
