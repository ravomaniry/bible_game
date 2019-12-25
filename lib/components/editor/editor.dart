import 'package:bible_game/components/editor/form.dart';
import 'package:bible_game/redux/editor/view_model.dart';
import 'package:bible_game/redux/themes/themes.dart';
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
          OkButton(
            theme: viewModel.theme,
            onClick: viewModel.closeHandler,
          ),
        ],
      ),
    );
  }
}

class OkButton extends StatelessWidget {
  final Function onClick;
  final AppColorTheme theme;

  OkButton({
    @required this.onClick,
    @required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: RaisedButton(
        color: theme.primary,
        key: Key("editorOkBtn"),
        onPressed: onClick,
        child: Icon(
          Icons.thumb_up,
          color: theme.neutral,
        ),
      ),
    );
  }
}
