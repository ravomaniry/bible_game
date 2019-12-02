import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:bible_game/statics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix4_transform/matrix4_transform.dart';

class WordsInWordControls extends StatelessWidget {
  final WordsInWordViewModel _viewModel;

  WordsInWordControls(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            PropositionDisplay(_viewModel.proposition, _viewModel.propose),
            SlotsDisplay(
              _viewModel.slots,
              _viewModel.slotClickHandler,
              _viewModel.shuffleSlots,
              _viewModel.slotIndexes,
            ),
          ],
        ),
      ),
    );
  }
}

class PropositionDisplay extends StatelessWidget {
  final List<Char> _proposition;
  final Function() _propose;

  PropositionDisplay(this._proposition, this._propose);

  Function get clickHandler {
    if (_proposition.length > 0) {
      return _propose;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: MediaQuery.of(context).size.width,
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: WordInWordsStyles.unrevealedWordColor),
        ),
        key: Key("proposeBtn"),
        padding: EdgeInsets.all(0),
        onPressed: clickHandler,
        child: Text(
          _proposition.map((x) => x.value).join(""),
        ),
      ),
    );
  }
}

class SlotsDisplay extends StatelessWidget {
  final List<Char> _slots;
  final Function(int) _onClick;
  final Function() _shuffle;
  final List<List<int>> _indexes;

  SlotsDisplay(this._slots, this._onClick, this._shuffle, this._indexes);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: GestureDetector(
        onHorizontalDragEnd: (_) => _shuffle(),
        child: Column(
          children: _indexes.map(_buildRow).toList(),
        ),
      ),
    );
  }

  Widget _buildRow(List<int> row) {
    if (row.length > 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: row.map((i) => SlotItem(_slots[i], i, _onClick)).toList(),
      );
    }
    return SizedBox.shrink();
  }
}

class SlotItem extends StatelessWidget {
  final Char _slot;
  final int _index;
  final Function(int) _onClick;
  static final double width = 34;
  static final double margin = 2;

  SlotItem(this._slot, this._index, this._onClick);

  Function() get onClick {
    if (_slot == null) {
      return () {};
    }
    return () => _onClick(_index);
  }

  Matrix4 get transform {
    if (_slot == null) {
      return Matrix4Transform().rotateDegrees(90, origin: Offset(17, 17)).matrix4;
    }
    return Matrix4Transform().rotateDegrees(0, origin: Offset(17, 17)).matrix4;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key("slot_$_index"),
      onTap: onClick,
      child: AnimatedContainer(
        transform: transform,
        duration: Duration(milliseconds: 120),
        decoration: _getDecoration(),
        alignment: Alignment.center,
        margin: EdgeInsets.only(right: margin, bottom: margin),
        width: width,
        height: width,
        child: Text(_slot?.value ?? "", style: WordInWordsStyles.slotTextStyle),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    if (_slot == null) {
      return WordInWordsStyles.visitedSlotDecoration;
    }
    return WordInWordsStyles.availSlotDecoration;
  }
}
