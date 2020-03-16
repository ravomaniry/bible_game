import 'package:animator/animator.dart';
import 'package:bible_game/app/inventory/combo_viem_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class ComboDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: ComboViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, ComboViewModel viewModel) {
    if (viewModel.combo == 1) {
      return SizedBox(height: 4);
    }
    return Animator(
      duration: Duration(seconds: 20),
      builder: (Animation anim) => Container(
        width: MediaQuery.of(context).size.width * (1 - anim.value),
        height: 4,
        decoration: BoxDecoration(color: viewModel.theme.accentRight),
      ),
    );
  }
}
