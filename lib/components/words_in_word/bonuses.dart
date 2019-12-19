import 'package:bible_game/components/inventory/shop.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:flutter/widgets.dart';

final _revealCharBonus1 = RevealCharBonus1();
final _revealCharBonus2 = RevealCharBonus2();
final _revealCharBonus5 = RevealCharBonus5();
final _revealCharBonus10 = RevealCharBonus10();

class BonusesDisplay extends StatelessWidget {
  final WordsInWordViewModel _viewModel;

  BonusesDisplay(this._viewModel);

  @override
  Widget build(BuildContext context) {
    final inventory = _viewModel.inventory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RevealCharDisplayWrapper(
              bonus: _revealCharBonus1,
              theme: _viewModel.theme,
              number: inventory.revealCharBonus1,
              useBonus: _viewModel.useBonus,
            ),
            _RevealCharDisplayWrapper(
              bonus: _revealCharBonus2,
              theme: _viewModel.theme,
              number: inventory.revealCharBonus2,
              useBonus: _viewModel.useBonus,
            ),
            _RevealCharDisplayWrapper(
              bonus: _revealCharBonus5,
              theme: _viewModel.theme,
              number: inventory.revealCharBonus5,
              useBonus: _viewModel.useBonus,
            ),
            _RevealCharDisplayWrapper(
              bonus: _revealCharBonus10,
              theme: _viewModel.theme,
              number: inventory.revealCharBonus10,
              useBonus: _viewModel.useBonus,
            ),
          ],
        ),
      ],
    );
  }
}

class _RevealCharDisplayWrapper extends StatelessWidget {
  final RevealCharBonus bonus;
  final int number;
  final Function(Bonus) useBonus;
  final AppColorTheme theme;

  _RevealCharDisplayWrapper({
    @required this.bonus,
    @required this.number,
    @required this.useBonus,
    @required this.theme,
  });

  Function() get _onPressed {
    if (number > 0) {
      return () => useBonus(RevealCharBonus(bonus.power, 0));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return RevealCharBonusDisplay(
      bonus: bonus,
      number: number,
      disabled: number == 0,
      onPressed: _onPressed,
      theme: theme,
    );
  }
}
