import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:bible_game/statics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WordsInWordControls extends StatelessWidget {
  final WordsInWordViewModel _viewModel;

  WordsInWordControls(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          PropositionDisplay(_viewModel.proposition, _viewModel.propose),
          SlotsDisplay(_viewModel.slots, _viewModel.slotClickHandler),
        ],
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
    return MaterialButton(
      key: Key("proposeBtn"),
      onPressed: clickHandler,
      child: Text(
        _proposition.map((x) => x.value).join(""),
      ),
    );
  }
}

class SlotsDisplay extends StatelessWidget {
  final List<Char> _slots;
  final Function(int) _onClick;

  SlotsDisplay(this._slots, this._onClick);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Wrap(
          direction: Axis.horizontal,
          runAlignment: WrapAlignment.center,
          alignment: WrapAlignment.center,
          runSpacing: 4,
          children: _slots.asMap().map((i, slot) => MapEntry(i, SlotItem(slot, i, _onClick))).values.toList()),
    );
  }
}

class SlotItem extends StatelessWidget {
  final Char _slot;
  final int _index;
  final Function(int) _onClick;

  SlotItem(this._slot, this._index, this._onClick);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _getDecoration(),
      alignment: Alignment.center,
      margin: EdgeInsets.only(right: 2),
      width: 34,
      height: 34,
      child: MaterialButton(
        key: Key("slot_$_index"),
        padding: EdgeInsets.all(0),
        onPressed: () => _onClick(_index),
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
