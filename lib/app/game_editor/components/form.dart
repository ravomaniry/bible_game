import 'package:bible_game/app/game_editor/view_model.dart';
import 'package:bible_game/app/texts.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/db/model.dart';
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
        VersePickerSection(
          mode: "start",
          key: Key("startSection"),
          texts: _viewModel.texts,
          label: _viewModel.texts.start,
          theme: _viewModel.theme,
          books: _viewModel.books,
          book: _viewModel.state.startBook,
          bookChangeHandler: _viewModel.startBookChangeHandler,
          chapter: _viewModel.state.startChapter,
          maxChapter: _getMaxChapter(_viewModel.state.startBook),
          chapterChangeHandler: _viewModel.startChapterChangeHandler,
          verse: _viewModel.state.startVerse,
          maxVerse: _getMaxVerse(_viewModel.state.startBook, _viewModel.state.startChapter),
          verseChangeHandler: _viewModel.startVerseChangeHandler,
        ),
        VersePickerSection(
          mode: "end",
          key: Key("endSection"),
          texts: _viewModel.texts,
          label: _viewModel.texts.end,
          theme: _viewModel.theme,
          books: _endBooks,
          book: _viewModel.state.endBook,
          bookChangeHandler: _viewModel.endBookChangeHandler,
          chapter: _viewModel.state.endChapter,
          minChapter: _minEndChapter,
          maxChapter: _getMaxChapter(_viewModel.state.endBook),
          chapterChangeHandler: _viewModel.endChapterChangeHandler,
          verse: _viewModel.state.endVerse,
          minVerse: _minEndVerse,
          maxVerse: _getMaxVerse(_viewModel.state.endBook, _viewModel.state.endChapter),
          verseChangeHandler: _viewModel.endVerseChangeHandler,
        ),
      ],
    );
  }

  int _getMaxChapter(int bookId) {
    return _viewModel.books.firstWhere((b) => b.id == bookId).chapters;
  }

  int _getMaxVerse(int bookId, int chapter) {
    final numMatch =
        _viewModel.state.versesNumRefs.where((v) => v.isSameRef(bookId, chapter)).toList();
    if (numMatch.length > 0) {
      return numMatch[0].versesNum;
    }
    return 1;
  }

  int get _minEndChapter {
    if (_viewModel.state.endBook > _viewModel.state.startBook) {
      return 1;
    }
    return _viewModel.state.startChapter;
  }

  int get _minEndVerse {
    if (_viewModel.state.endBook == _viewModel.state.startBook &&
        _viewModel.state.endChapter == _viewModel.state.startChapter) {
      return _viewModel.state.startVerse;
    }
    return 1;
  }

  List<BookModel> get _endBooks {
    return _viewModel.books.where((b) => b.id >= _viewModel.state.startBook).toList();
  }
}

class VersePickerSection extends StatelessWidget {
  final String label;
  final String mode;
  final List<BookModel> books;
  final int book;
  final Function(int) bookChangeHandler;
  final int chapter;
  final int minChapter;
  final int maxChapter;
  final Function(int) chapterChangeHandler;
  final int verse;
  final int minVerse;
  final int maxVerse;
  final Function(int) verseChangeHandler;
  final AppColorTheme theme;
  final AppTexts texts;
  final Key key;

  VersePickerSection({
    @required this.texts,
    @required this.label,
    @required this.mode,
    @required this.books,
    @required this.book,
    @required this.bookChangeHandler,
    @required this.chapter,
    this.minChapter = 1,
    @required this.maxChapter,
    @required this.chapterChangeHandler,
    @required this.verse,
    this.minVerse = 1,
    @required this.maxVerse,
    @required this.verseChangeHandler,
    @required this.theme,
    @required this.key,
  }) : super(key: key);

  List<int> get _versesList {
    return List<int>.generate(maxVerse - minVerse + 1, (i) => minVerse + i);
  }

  List<int> get _chaptersList {
    return List<int>.generate(maxChapter - minChapter + 1, (i) => minChapter + i);
  }

  int _numberValueAccessor(int i) {
    return i;
  }

  String _numberTextAccessor(int i) {
    return i.toString();
  }

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      label: label,
      theme: theme,
      children: [
        _SectionText(
          value: label,
          theme: theme,
        ),
        Column(
          children: [
            Row(
              children: [
                _RowText(texts.book),
                _BookPicker(
                  keyValue: "${mode}Book",
                  books: books,
                  value: book,
                  changeHandler: bookChangeHandler,
                ),
              ],
            ),
            Row(
              children: [
                _RowText(texts.chapter),
                GenericDropdown(
                  keyValue: "${mode}Chapter",
                  value: chapter,
                  list: _chaptersList,
                  valueAccessor: _numberValueAccessor,
                  textAccessor: _numberTextAccessor,
                  changeHandler: chapterChangeHandler,
                ),
              ],
            ),
            Row(
              children: [
                _RowText(texts.verse),
                GenericDropdown(
                  keyValue: "${mode}Verse",
                  value: verse,
                  list: _versesList,
                  valueAccessor: _numberValueAccessor,
                  textAccessor: _numberTextAccessor,
                  changeHandler: verseChangeHandler,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionText extends StatelessWidget {
  final String value;
  final AppColorTheme theme;

  _SectionText({
    @required this.value,
    @required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        color: theme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  final List<Widget> children;
  final String label;
  final AppColorTheme theme;

  _SectionContainer({
    @required this.children,
    @required this.label,
    @required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.neutral,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _BookPicker extends StatelessWidget {
  final List<BookModel> books;
  final int value;
  final String keyValue;
  final Function(int) changeHandler;

  _BookPicker({
    @required this.keyValue,
    @required this.books,
    @required this.value,
    @required this.changeHandler,
  }) : super(key: Key(keyValue));

  int valueAccessor(BookModel book) => book.id;

  String textAccessor(BookModel book) => book.name;

  @override
  Widget build(BuildContext context) {
    return GenericDropdown<BookModel>(
      value: value,
      list: books,
      keyValue: keyValue,
      changeHandler: changeHandler,
      valueAccessor: valueAccessor,
      textAccessor: textAccessor,
    );
  }
}

class GenericDropdown<ItemType> extends StatelessWidget {
  final int value;
  final String keyValue;
  final List<ItemType> list;
  final Function(int) changeHandler;
  final int Function(ItemType item) valueAccessor;
  final String Function(ItemType item) textAccessor;

  GenericDropdown({
    @required this.list,
    @required this.value,
    @required this.changeHandler,
    @required this.valueAccessor,
    @required this.textAccessor,
    @required this.keyValue,
  }) : super(key: Key("generic_$keyValue"));

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: DropdownButton<int>(
        key: Key("_$keyValue"),
        value: value,
        onChanged: changeHandler,
        items: _buildItems(),
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

class _RowText extends StatelessWidget {
  final String _value;

  _RowText(this._value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Text(_value),
    );
  }
}
