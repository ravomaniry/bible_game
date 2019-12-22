import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/game/editor_view_model.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EditorDialog extends StatelessWidget {
  final EditorViewModel _viewModel;

  EditorDialog(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return _DialogContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _EditorForm(_viewModel),
          _OkButton(
            theme: _viewModel.theme,
            onPressed: _viewModel.toggleDialog,
          )
        ],
      ),
    );
  }
}

class _DialogContainer extends StatelessWidget {
  final Widget child;

  _DialogContainer({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(180, 0, 0, 0),
      ),
      child: Dialog(
        child: child,
      ),
    );
  }
}

class _OkButton extends StatelessWidget {
  final AppColorTheme theme;
  final Function onPressed;

  _OkButton({
    @required this.theme,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: RaisedButton(
        color: theme.primary,
        key: Key("closeEditorDialog"),
        onPressed: onPressed,
        child: Icon(
          Icons.thumb_up,
          color: theme.neutral,
        ),
      ),
    );
  }
}

class _EditorForm extends StatelessWidget {
  final EditorViewModel _viewModel;

  _EditorForm(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _BookPicker(
          books: _viewModel.state.books,
          value: _viewModel.state.formData.startBook,
          selectHandler: _viewModel.startBookChangeHandler,
        ),
        _NumberPicker(
          label: "Toko",
          value: 1,
          min: 1,
          max: 10,
          selectHandler: (_) {},
        ),
      ],
    );
  }
}

class _BookPicker extends StatelessWidget {
  final List<BookModel> books;
  final int value;
  final Function(int) selectHandler;

  _BookPicker({
    @required this.books,
    @required this.value,
    @required this.selectHandler,
  });

  int valueAccessor(BookModel book) => book.id;

  String textAccessor(BookModel book) => book.name;

  @override
  Widget build(BuildContext context) {
    return _GenericDropdown<BookModel>(
      label: "Boky",
      value: value,
      list: books,
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
  final Function(int) selectHandler;

  _NumberPicker({
    @required this.label,
    @required this.min,
    @required this.max,
    @required this.value,
    @required this.selectHandler,
  });

  int valueAccessor(int value) => value;

  String textAccessor(int value) => value.toString();

  @override
  Widget build(BuildContext context) {
    return _GenericDropdown(
      list: _list,
      label: label,
      value: value,
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
        .map((item) => DropdownMenuItem<int>(
              key: Key(valueAccessor(item).toString()),
              value: valueAccessor(item),
              child: Text(textAccessor(item)),
            ))
        .toList();
  }
}
