import 'package:bible_game/app/game_editor/components/editor.dart';
import 'package:bible_game/app/help/components/gallery.dart';
import 'package:bible_game/app/help/components/models.dart';
import 'package:bible_game/app/help/components/text.dart';
import 'package:bible_game/app/help/view_model.dart';
import 'package:bible_game/app/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Help extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreConnector(
        converter: converter,
        builder: _builder,
      ),
    );
  }

  Widget _builder(BuildContext _, HelpViewModel viewModel) {
    if (viewModel.state?.value == null) {
      return SplashScreen();
    }
    return Column(
      children: [
        _HelpBody(viewModel),
        _HelpButton(viewModel),
      ],
    );
  }
}

class _HelpBody extends StatelessWidget {
  final HelpViewModel _viewModel;

  _HelpBody(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        key: Key("helpScreen"),
        children: [
          for (final item in _viewModel.state.value)
            if (item is HelpSection)
              HelpText(item, _viewModel.theme, key: item.key)
            else if (item is HelpGallery)
              Gallery(item, _viewModel.theme, key: item.key)
        ],
      ),
    );
  }
}

class _HelpButton extends StatelessWidget {
  final HelpViewModel _viewModel;

  _HelpButton(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OkButton(
        btnKey: "closeHelpBtn",
        theme: _viewModel.theme,
        onClick: _viewModel.closeHandler,
      ),
    );
  }
}
