import 'package:bible_game/models/bonus.dart';

class OpenInventoryDialog {
  final bool isInGame;

  OpenInventoryDialog(this.isInGame);
}

class CloseInventoryDialog {}

final closeInventoryDialog = CloseInventoryDialog();

class BuyBonus {
  final Bonus payload;

  BuyBonus(this.payload);
}
