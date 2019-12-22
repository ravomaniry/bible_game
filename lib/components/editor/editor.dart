import 'package:bible_game/components/editor/form.dart';
import 'package:bible_game/redux/editor/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class GameEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      key: Key("gameEditor"),
      converter: EditorViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, EditorViewModel viewModel) {
    return Scaffold(
      body: Column(
        children: [
          EditorForm(viewModel),
          _OkButton(viewModel),
        ],
      ),
    );
  }
}

class _OkButton extends StatelessWidget {
  final EditorViewModel _viewModel;

  _OkButton(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: RaisedButton(
        color: _viewModel.theme.primary,
        key: Key("editorOkBtn"),
        onPressed: _viewModel.closeHandler,
        child: Icon(
          Icons.thumb_up,
          color: _viewModel.theme.neutral,
        ),
      ),
    );
  }
}
