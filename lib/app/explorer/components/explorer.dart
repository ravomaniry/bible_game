import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/components/splash_screen.dart';
import 'package:bible_game/app/explorer/view_model.dart';
import 'package:bible_game/app/game_editor/components/editor.dart';
import 'package:bible_game/app/game_editor/components/form.dart';
import 'package:bible_game/db/model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Explorer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ExplorerViewModel>(
      key: Key("explorer"),
      builder: _builder,
      converter: ExplorerViewModel.converter,
    );
  }

  Widget _builder(BuildContext context, ExplorerViewModel viewModel) {
    if (viewModel.books == null) {
      return SplashScreen();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: viewModel.theme.primary,
        title: Text(viewModel.texts.explorer),
      ),
      body: _body(viewModel),
    );
  }

  Widget _body(ExplorerViewModel viewModel) {
    if (viewModel.state.submitted) {
      return _VerseDisplay(viewModel);
    } else {
      return _Form(viewModel);
    }
  }
}

class _Form extends StatelessWidget {
  final ExplorerViewModel _viewModel;

  _Form(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key("explorerForm"),
      children: <Widget>[
        VersePickerSection(
          label: "",
          mode: "explorer",
          theme: _viewModel.theme,
          texts: _viewModel.texts,
          key: Key("explorerVersePicker"),
          books: _viewModel.books,
          book: _viewModel.state.activeBook,
          bookChangeHandler: _viewModel.bookChangeHandler,
          chapter: _viewModel.state.activeChapter,
          minChapter: 1,
          maxChapter: _maxChapter,
          chapterChangeHandler: _viewModel.chapterChangeHandler,
          minVerse: 1,
          maxVerse: _maxVerse,
          verse: _viewModel.state.activeVerse,
          verseChangeHandler: _viewModel.verseChangeHandler,
        ),
        OkButton(
          theme: _viewModel.theme,
          onClick: _viewModel.submitHandler,
        ),
      ],
    );
  }

  int get _maxChapter {
    return _viewModel.books.firstWhere((b) => b.id == _viewModel.state.activeBook).chapters;
  }

  int get _maxVerse {
    final state = _viewModel.state;
    final match = _viewModel.versesNumRef
        .where((n) => n.isSameRef(state.activeBook, state.activeChapter))
        .toList();
    return match.isEmpty ? 1 : match.first.versesNum;
  }
}

class _VerseDisplay extends StatelessWidget {
  final ExplorerViewModel _viewModel;

  _VerseDisplay(this._viewModel);

  @override
  Widget build(BuildContext context) {
    final verses = _viewModel.state.verses;
    if (verses == null) {
      return SizedBox.shrink();
    } else {
      return ListView(
        key: Key("explorerVersesDisplay"),
        children: [for (final verse in verses) _itemBuilder(verse)],
      );
    }
  }

  Widget _itemBuilder(VerseModel verse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${verse.verse}",
          style: TextStyle(
            color: _viewModel.theme.primary,
          ),
        ),
        Text(verse.text),
      ],
    );
  }
}
