import 'package:bible_game/statics/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Footer extends StatelessWidget {
  final Function() _closeHandler;

  Footer(this._closeHandler);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          TextValues.bonusPriceNote,
        ),
        RaisedButton(
          key: Key("inventoryOkButton"),
          onPressed: _closeHandler,
          child: Text(TextValues.ok),
        ),
      ],
    );
  }
}
