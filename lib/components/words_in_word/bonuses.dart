import 'package:bible_game/components/inventory/shop.dart';
import 'package:bible_game/models/bonus.dart';
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
          children: [
            _RevealCharDisplayWrapper(_revealCharBonus1, inventory.revealCharBonus1, _viewModel.useBonus),
            _RevealCharDisplayWrapper(_revealCharBonus2, inventory.revealCharBonus2, _viewModel.useBonus),
            _RevealCharDisplayWrapper(_revealCharBonus5, inventory.revealCharBonus5, _viewModel.useBonus),
            _RevealCharDisplayWrapper(_revealCharBonus10, inventory.revealCharBonus10, _viewModel.useBonus),
          ],
        ),
        Text("${_viewModel.inventory.money} Ar.")
      ],
    );
  }
}

class _RevealCharDisplayWrapper extends StatelessWidget {
  final RevealCharBonus _bonus;
  final int _number;
  final Function(Bonus) _useBonus;

  _RevealCharDisplayWrapper(this._bonus, this._number, this._useBonus);

  Function() get _onPressed {
    if (_number > 0) {
      return () => _useBonus(RevealCharBonus(_bonus.power, 0));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return RevealCharBonusDisplay(_bonus, _number, _onPressed);
  }
}
