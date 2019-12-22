import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/editor/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EditorForm extends StatelessWidget {
  final EditorViewModel _viewModel;

  EditorForm(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _BookPicker(
          keyValue: "startBook",
          books: _viewModel.books,
          value: _viewModel.state.startBook,
          selectHandler: _viewModel.startBookChangeHandler,
        ),
        _NumberPicker(
          keyValue: "startChapter",
          label: "Toko",
          value: _viewModel.state.startChapter,
          min: 1,
          max: _getMaxStartChapter(_viewModel.state.startBook),
          selectHandler: _viewModel.startChapterChangeHandler,
        ),
        _NumberPicker(
          keyValue: "startVerse",
          label: "Andininy",
          value: _viewModel.state.startVerse,
          min: 1,
          max: _getMaxStartVerse(_viewModel.state.startBook, _viewModel.state.startChapter),
          selectHandler: _viewModel.startVerseChangeHandler,
        ),
      ],
    );
  }

  int _getMaxStartChapter(int bookId) {
    return _viewModel.books.firstWhere((b) => b.id == bookId).chapters;
  }

  int _getMaxStartVerse(int bookId, int chapter) {
    final numMatch = _viewModel.state.versesNumRefs.where((v) => v.isSameRef(bookId, chapter)).toList();
    if (numMatch.length > 0) {
      return numMatch[0].versesNum;
    }
    return 1;
  }
}

class _BookPicker extends StatelessWidget {
  final List<BookModel> books;
  final int value;
  final String keyValue;
  final Function(int) selectHandler;

  _BookPicker({
    @required this.keyValue,
    @required this.books,
    @required this.value,
    @required this.selectHandler,
  }) : super(key: Key(keyValue));

  int valueAccessor(BookModel book) => book.id;

  String textAccessor(BookModel book) => book.name;

  @override
  Widget build(BuildContext context) {
    return _GenericDropdown<BookModel>(
      label: "Boky",
      value: value,
      list: books,
      keyValue: keyValue,
      selectHandler: selectHandler,
      valueAccessor: valueAccessor,
      textAccessor: textAccessor,
    );
  }
}

class _NumberPicker extends StatelessWidget {
  final String label;
  final int min;
  final int max;
  final int value;
  final String keyValue;
  final Function(int) selectHandler;

  _NumberPicker({
    @required this.keyValue,
    @required this.label,
    @required this.min,
    @required this.max,
    @required this.value,
    @required this.selectHandler,
  }) : super(key: Key(keyValue));

  int valueAccessor(int value) => value;

  String textAccessor(int value) => value.toString();

  @override
  Widget build(BuildContext context) {
    return _GenericDropdown(
      list: _list,
      label: label,
      value: value,
      keyValue: keyValue,
      valueAccessor: valueAccessor,
      textAccessor: textAccessor,
      selectHandler: selectHandler,
    );
  }

  List<int> get _list {
    final intsList = List<int>(max - min + 1);
    for (var i = 0; i < intsList.length; i++) {
      intsList[i] = min + i;
    }
    return intsList;
  }
}

class _GenericDropdown<ItemType> extends StatelessWidget {
  final String label;
  final int value;
  final String keyValue;
  final List<ItemType> list;
  final Function(int) selectHandler;
  final int Function(ItemType item) valueAccessor;
  final String Function(ItemType item) textAccessor;

  _GenericDropdown({
    @required this.label,
    @required this.list,
    @required this.value,
    @required this.selectHandler,
    @required this.valueAccessor,
    @required this.textAccessor,
    @required this.keyValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Text(label),
          DropdownButton<int>(
            value: value,
            onChanged: selectHandler,
            items: _buildItems(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItems() {
    return list
        .map(
          (item) => DropdownMenuItem<int>(
            key: Key("${keyValue}_${valueAccessor(item)}"),
            value: valueAccessor(item),
            child: Text(textAccessor(item)),
          ),
        )
        .toList();
  }
}
