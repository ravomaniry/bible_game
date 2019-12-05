import 'package:bible_game/statics/styles.dart';
import 'package:flutter/widgets.dart';

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: InventoryStyles.innerDecoration,
      child: Text("Bonus"),
    );
  }
}
