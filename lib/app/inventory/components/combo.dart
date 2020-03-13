import 'package:animator/animator.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/widgets.dart';

class ComboDisplay extends StatelessWidget {
  final double combo;
  final AppColorTheme theme;

  ComboDisplay({
    @required this.combo,
    @required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (combo == 1) {
      return SizedBox(height: 4);
    }
    return Animator(
      duration: Duration(seconds: 20),
      builder: (Animation anim) => Container(
        width: MediaQuery.of(context).size.width * (1 - anim.value),
        height: 4,
        decoration: BoxDecoration(color: theme.accentRight),
      ),
    );
  }
}
