import 'package:animator/animator.dart';
import 'package:bible_game/components/words_in_word/bonuses.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix4_transform/matrix4_transform.dart';

final double slotWidth = 34;
final double slotMargin = 2;

class WordsInWordControls extends StatelessWidget {
  final WordsInWordViewModel _viewModel;

  WordsInWordControls(this._viewModel);

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.wordsInWord;
    return _ControlsContainer(
      theme: _viewModel.theme,
      child: Column(
        children: [
          _PropositionDisplay(
            theme: _viewModel.theme,
            proposition: state.proposition,
            propose: _viewModel.propose,
          ),
          _ComboDisplay(
            combo: _viewModel.inventory.combo,
            invalidateCombo: _viewModel.invalidateCombo,
            theme: _viewModel.theme,
          ),
          _SlotsDisplay(
            slots: state.slots,
            onSlotClick: _viewModel.slotClickHandler,
            shuffle: _viewModel.shuffleSlots,
            indexes: state.slotsDisplayIndexes,
            theme: _viewModel.theme,
          ),
          SizedBox(height: 15),
          BonusesDisplay(_viewModel),
        ],
      ),
    );
  }
}

class _ControlsContainer extends StatelessWidget {
  final Widget child;
  final AppColorTheme theme;

  _ControlsContainer({@required this.theme, @required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary.withAlpha(40), Colors.transparent],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.75, 1],
        ),
      ),
      child: child,
    );
  }
}

class _PropositionDisplay extends StatelessWidget {
  final Function() propose;
  final List<Char> proposition;
  final AppColorTheme theme;

  _PropositionDisplay({
    @required this.proposition,
    @required this.propose,
    @required this.theme,
  });

  Function get clickHandler {
    if (proposition.length > 0) {
      return propose;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return _PropositionContainer(
      theme: theme,
      clickHandler: clickHandler,
      text: proposition.map((x) => x.value).join(""),
    );
  }
}

class _PropositionContainer extends StatelessWidget {
  final String text;
  final AppColorTheme theme;
  final Function clickHandler;

  _PropositionContainer({
    @required this.clickHandler,
    @required this.text,
    @required this.theme,
  });

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
            color: theme.neutral.withAlpha(240),
            border: Border.all(
              color: theme.neutral,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: FlatButton(
            key: Key("proposeBtn"),
            splashColor: Colors.white,
            padding: EdgeInsets.only(top: 0, bottom: 0, left: 30, right: 30),
            onPressed: clickHandler,
            child: Text(
              text,
              style: TextStyle(
                color: theme.primaryDark,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _SlotsDisplay extends StatelessWidget {
  final List<Char> slots;
  final Function(int) onSlotClick;
  final Function() shuffle;
  final List<List<int>> indexes;
  final AppColorTheme theme;

  _SlotsDisplay({
    @required this.slots,
    @required this.onSlotClick,
    @required this.shuffle,
    @required this.indexes,
    @required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: GestureDetector(
        onHorizontalDragEnd: (_) => shuffle(),
        child: Column(
          children: indexes.map(_buildRow).toList(),
        ),
      ),
    );
  }

  Widget _buildRow(List<int> row) {
    if (row.length > 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: row
            .map((i) => _SlotItem(
                  slot: slots[i],
                  index: i,
                  onClick: onSlotClick,
                  theme: theme,
                ))
            .toList(),
      );
    }
    return SizedBox.shrink();
  }
}

class _SlotItem extends StatelessWidget {
  final Char slot;
  final int index;
  final Function(int) onClick;
  final AppColorTheme theme;

  _SlotItem({
    @required this.slot,
    @required this.index,
    @required this.onClick,
    @required this.theme,
  });

  Function() get _tapCallback {
    if (slot == null) {
      return () {};
    }
    return () => onClick(index);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key("slot_$index"),
      onTap: _tapCallback,
      child: _SlotItemContainer(
        theme: theme,
        isEmpty: slot == null,
        child: Text(
          slot?.value ?? "",
          style: TextStyle(
            color: theme.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SlotItemContainer extends StatelessWidget {
  final bool isEmpty;
  final AppColorTheme theme;
  final Widget child;

  _SlotItemContainer({
    @required this.isEmpty,
    @required this.theme,
    @required this.child,
  });

  Matrix4 get transform {
    if (isEmpty) {
      return Matrix4Transform().rotateDegrees(90, origin: Offset(17, 17)).matrix4;
    }
    return Matrix4Transform().rotateDegrees(0, origin: Offset(17, 17)).matrix4;
  }

  int get _alpha {
    return isEmpty ? 120 : 160;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      transform: transform,
      duration: Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: theme.neutral.withAlpha(_alpha),
        border: Border.all(
          color: theme.neutral.withAlpha(80),
          width: 4,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      margin: EdgeInsets.only(right: slotMargin, bottom: slotMargin),
      width: slotWidth,
      height: slotWidth,
      child: child,
    );
  }
}

class _ComboDisplay extends StatelessWidget {
  final double combo;
  final Function() invalidateCombo;
  final AppColorTheme theme;

  _ComboDisplay({
    @required this.combo,
    @required this.invalidateCombo,
    @required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (combo == 1) {
      return SizedBox(height: 4);
    }
    return Animator(
      duration: Duration(seconds: 20),
      endAnimationListener: (_) => invalidateCombo(),
      builder: (Animation anim) => Container(
        width: MediaQuery.of(context).size.width * (1 - anim.value),
        height: 4,
        decoration: BoxDecoration(color: theme.primaryDark),
      ),
    );
  }
}
