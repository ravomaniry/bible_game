import 'package:bible_game/components/loader.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/explorer/view_model.dart';
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
      return Loader();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Explorer"),
      ),
      body: _body(viewModel),
    );
  }

  Widget _body(ExplorerViewModel viewModel) {
    if (viewModel.activeBook == null) {
      return ListView(
        key: Key("booksList"),
        children: viewModel.books.map((book) => BookListItem(book, viewModel.loadVerses)).toList(),
      );
    } else {
      return VerseDetails(viewModel);
    }
  }
}

class BookListItem extends StatelessWidget {
  final BookModel _book;
  final Function(BookModel) _onPressed;

  BookListItem(this._book, this._onPressed) : super(key: Key(_book.id.toString()));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: MaterialButton(
        onPressed: () => _onPressed(_book),
        child: Row(
          children: <Widget>[
            Text(
              "${_book.id} ",
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
            Text(_book.name),
          ],
        ),
      ),
    );
  }
}

class VerseDetails extends StatelessWidget {
  final ExplorerViewModel _viewModel;

  VerseDetails(this._viewModel);

  @override
  Widget build(BuildContext context) {
    if (_viewModel.verses == null) {
      return Loader();
    }
    return Scaffold(
      key: Key("verseDetails"),
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Expanded(child: Text(_viewModel.activeBook.name)),
            RaisedButton(
              key: Key("verseDetailsBackBtn"),
              child: Text("Back"),
              onPressed: _viewModel.goToBooksList,
            ),
          ],
        ),
      ),
      body: ListView(
        children: _viewModel.verses
            .map((verse) => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "${verse.chapter}: ${verse.verse}",
                      style: TextStyle(color: Colors.blue),
                    ),
                    Text(verse.text),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
