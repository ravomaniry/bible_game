import 'package:bible_game/app/inventory/components/shop.dart';
import 'package:bible_game/app/inventory/in_game_bonus_view_model.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

final _revealCharBonus1 = RevealCharBonus1();
final _revealCharBonus2 = RevealCharBonus2();
final _revealCharBonus5 = RevealCharBonus5();
final _revealCharBonus10 = RevealCharBonus10();

class InGameBonuses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: InGameBonusViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(_, InGameBonusViewModel viewModel) {
    final inventory = viewModel.inventory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RevealCharDisplayWrapper(
              bonus: _revealCharBonus1,
              theme: viewModel.theme,
              number: inventory.revealCharBonus1,
              useBonus: viewModel.use,
            ),
            _RevealCharDisplayWrapper(
              bonus: _revealCharBonus2,
              theme: viewModel.theme,
              number: inventory.revealCharBonus2,
              useBonus: viewModel.use,
            ),
            _RevealCharDisplayWrapper(
              bonus: _revealCharBonus5,
              theme: viewModel.theme,
              number: inventory.revealCharBonus5,
              useBonus: viewModel.use,
            ),
            _RevealCharDisplayWrapper(
              bonus: _revealCharBonus10,
              theme: viewModel.theme,
              number: inventory.revealCharBonus10,
              useBonus: viewModel.use,
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
