import 'package:bible_game/components/game/in_game_header.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/game/view_model.dart';
import 'package:bible_game/redux/themes/themes.dart';
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

    return _SolutionContainer(
      theme: _viewModel.theme,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            verse.text,
            style: const TextStyle(fontSize: 16),
          ),
          _VerseRef(
            verse: _viewModel.state.verse,
            theme: _viewModel.theme,
          ),
          _NextBtn(
            theme: _viewModel.theme,
            nextHandler: _viewModel.nextHandler,
          ),
        ],
      ),
    );
  }
}

class _SolutionContainer extends StatelessWidget {
  final AppColorTheme theme;
  final Widget child;

  _SolutionContainer({
    @required this.theme,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        key: Key("solutionScreen"),
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage(theme.background),
          ),
        ),
        child: Column(
          children: <Widget>[
            InGameHeader(),
            Expanded(child: Container()),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.neutral,
              ),
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(15),
              child: child,
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}

class _VerseRef extends StatelessWidget {
  final AppColorTheme theme;
  final BibleVerse verse;

  _VerseRef({
    @required this.theme,
    @required this.verse,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        "${verse.book} ${verse.chapter}: ${verse.verse}",
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: theme.primary,
        ),
      ),
    );
  }
}

class _NextBtn extends StatelessWidget {
  final AppColorTheme theme;
  final Function nextHandler;

  _NextBtn({@required this.theme, @required this.nextHandler});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      key: Key("nextButton"),
      color: theme.primary,
      onPressed: nextHandler,
      child: Icon(
        Icons.fast_forward,
        color: theme.neutral,
      ),
    );
  }
}
