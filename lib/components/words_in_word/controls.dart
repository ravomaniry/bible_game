import 'package:animator/animator.dart';
import 'package:bible_game/components/words_in_word/bonuses.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:bible_game/statics/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix4_transform/matrix4_transform.dart';

class WordsInWordControls extends StatelessWidget {
  final WordsInWordViewModel _viewModel;

  WordsInWordControls(this._viewModel);

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.wordsInWord;
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(100, 255, 255, 255),
      ),
      child: Column(
        children: [
          PropositionDisplay(state.proposition, _viewModel.propose),
          ComboDisplay(_viewModel.inventory.combo, _viewModel.invalidateCombo),
          SlotsDisplay(
            state.slots,
            _viewModel.slotClickHandler,
            _viewModel.shuffleSlots,
            state.slotsDisplayIndexes,
          ),
          SizedBox(height: 15),
          BonusesDisplay(_viewModel),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 32,
          constraints: const BoxConstraints(
            minWidth: 200,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage("assets/images/panels_with_nail.png"),
            ),
          ),
          child: FlatButton(
            key: Key("proposeBtn"),
            splashColor: Colors.white,
            padding: EdgeInsets.only(top: 0, bottom: 0, left: 30, right: 30),
            onPressed: clickHandler,
            child: Text(
              _proposition.map((x) => x.value).join(""),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        )
      ],
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
      margin: const EdgeInsets.only(top: 4),
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage("assets/images/word_block.png"),
          ),
        ),
        alignment: Alignment.center,
        margin: EdgeInsets.only(right: margin, bottom: margin),
        width: width,
        height: width,
        child: Text(
          _slot?.value ?? "",
          style: const TextStyle(
            color: Color.fromARGB(255, 93, 41, 44),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ComboDisplay extends StatelessWidget {
  final int _combo;
  final Function() _invalidateCombo;

  ComboDisplay(this._combo, this._invalidateCombo);

  @override
  Widget build(BuildContext context) {
    if (_combo == 1) {
      return SizedBox(height: 4);
    }
    return Animator(
      duration: Duration(seconds: 20),
      endAnimationListener: (_) => _invalidateCombo(),
      builder: (Animation anim) => Container(
        width: MediaQuery.of(context).size.width * (1 - anim.value),
        height: 4,
        decoration: BoxDecoration(color: WordInWordsStyles.revealedWordColor),
      ),
    );
  }
}
