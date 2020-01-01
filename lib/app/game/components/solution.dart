import 'package:bible_game/app/game/components/in_game_header.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/game/view_model.dart';
import 'package:bible_game/app/theme/themes.dart';
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
    if (viewModel.state.expandedVerses.isEmpty) {
      return _CollapsedVerse(viewModel);
    } else {
      return _ExpandedVerses(viewModel);
    }
  }
}

class _SolutionContainer extends StatelessWidget {
  final AppColorTheme theme;
  final Widget child;

  _SolutionContainer({
    @required this.theme,
    @required this.child,
    Key key,
  }) : super(key: key);

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
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _CollapsedVerse extends StatelessWidget {
  final GameViewModel _viewModel;

  _CollapsedVerse(this._viewModel);

  @override
  Widget build(BuildContext context) {
    final verse = _viewModel.state.verse;

    return _SolutionContainer(
      key: Key("expandedVerse"),
      theme: _viewModel.theme,
      child: _CollapsedContainer(
        theme: _viewModel.theme,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ExpandBtn(
              theme: _viewModel.theme,
              onClick: _viewModel.expandVersesHandler,
            ),
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
      ),
    );
  }
}

class _CollapsedContainer extends StatelessWidget {
  final AppColorTheme theme;
  final Widget child;

  _CollapsedContainer({
    @required this.theme,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
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
    );
  }
}

class _ExpandedVerses extends StatelessWidget {
  final GameViewModel _viewModel;

  _ExpandedVerses(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return _SolutionContainer(
      theme: _viewModel.theme,
      key: Key("expandedVerses"),
      child: _ExpandedContainer(
        theme: _viewModel.theme,
        listItems: _listItems,
        nextButton: _NextBtn(
          theme: _viewModel.theme,
          nextHandler: _viewModel.nextHandler,
        ),
      ),
    );
  }

  List<Widget> get _listItems {
    return _viewModel.state.expandedVerses
        .map((verse) => _ExpandedVerseListItem(
              theme: _viewModel.theme,
              verse: verse,
              activeVerse: _viewModel.state.verse,
            ))
        .toList();
  }
}

class _ExpandedContainer extends StatelessWidget {
  final AppColorTheme theme;
  final List<Widget> listItems;
  final Widget nextButton;

  _ExpandedContainer({
    @required this.theme,
    @required this.listItems,
    @required this.nextButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.neutral.withAlpha(200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              child: ListView(
                reverse: true,
                shrinkWrap: true,
                children: listItems,
              ),
            ),
          ),
          nextButton,
        ],
      ),
    );
  }
}

class _ExpandedVerseListItem extends StatelessWidget {
  final AppColorTheme theme;
  final VerseModel verse;
  final BibleVerse activeVerse;

  _ExpandedVerseListItem({
    @required this.theme,
    @required this.verse,
    @required this.activeVerse,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "${verse.verse} - ${verse.text}",
      style: _style,
    );
  }

  TextStyle get _style {
    if (this.verse.verse == activeVerse.verse) {
      return TextStyle(
        color: theme.primary,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
      );
    }
    return null;
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

  _NextBtn({
    @required this.theme,
    @required this.nextHandler,
  });

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

class _ExpandBtn extends StatelessWidget {
  final AppColorTheme theme;
  final Function onClick;

  _ExpandBtn({
    @required this.theme,
    @required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      decoration: BoxDecoration(
        color: theme.primary.withAlpha(230),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        key: Key("expandVersesBtn"),
        onPressed: onClick,
        padding: EdgeInsets.all(0),
        icon: Icon(
          Icons.more_horiz,
          color: theme.neutral,
        ),
      ),
    );
  }
}
