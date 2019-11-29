import 'package:bible_game/models/cell.dart';
import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:flutter/cupertino.dart';

class WordsInWordResult extends StatelessWidget {
  final WordsInWordViewModel _viewModel;

  WordsInWordResult(this._viewModel);

  void checkScreenWidth(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    if (_viewModel.screenWidth != currentWidth) {
      _viewModel.updateScreenWidth(currentWidth);
    }
  }

  @override
  Widget build(BuildContext context) {
    checkScreenWidth(context);
    final verse = _viewModel.verse;
    final cells = _viewModel.cells;

    if (verse != null && cells != null) {
      final List<Widget> rowWidgets = _viewModel.cells.map(_buildRow).toList();
      return Expanded(
        child: ListView(children: rowWidgets),
      );
    }
    return Text("Nothing to show!!!");
  }

  Widget _buildRow(List<Cell> _row) {
    return Row(children: _row.map((cell) => _buildCell(cell)).toList());
  }

  Widget _buildCell(Cell cell) {
    return SizedBox(
      key: Key("${cell.wordIndex}_${cell.charIndex}"),
      width: 20,
      height: 20,
      child: Center(
        child: Text(_viewModel.verse.words[cell.wordIndex].chars[cell.charIndex].value),
      ),
    );
  }
}
