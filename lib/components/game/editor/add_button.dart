import 'package:bible_game/redux/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AddButton extends StatelessWidget {
  final AppColorTheme theme;
  final Function onPressed;

  AddButton({
    @required this.theme,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 20,
      child: FloatingActionButton(
        backgroundColor: theme.accentLeft,
        key: Key("showEditorDialog"),
        child: Icon(
          Icons.add,
          size: 48,
          color: theme.neutral,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
