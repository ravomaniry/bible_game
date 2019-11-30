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
          SlotsDisplay(_viewModel.slots),
        ],
      ),
    );
  }
}

class SlotsDisplay extends StatelessWidget {
  final List<Char> _slots;

  SlotsDisplay(this._slots);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Wrap(
        direction: Axis.horizontal,
        runAlignment: WrapAlignment.center,
        alignment: WrapAlignment.center,
        runSpacing: 4,
        children: _slots.map((slot) => SlotItem(slot)).toList(),
      ),
    );
  }
}

class SlotItem extends StatelessWidget {
  final Char _slot;

  SlotItem(this._slot);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _getDecoration(),
      alignment: Alignment.center,
      margin: EdgeInsets.only(right: 2),
      width: 34,
      height: 34,
      child: MaterialButton(
        padding: EdgeInsets.all(0),
        onPressed: () => print("tapped ${_slot.value} $_slot"),
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
