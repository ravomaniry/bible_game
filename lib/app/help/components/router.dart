import 'package:bible_game/app/help/models.dart';
import 'package:bible_game/app/help/components/paragraph.dart';
import 'package:bible_game/app/help/components/section.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/widgets.dart';

Widget helpComponentRouter(HelpUiItem item, AppColorTheme theme) {
  if (item is HelpSection) {
    return HelpSectionView(item, theme);
  } else if (item is HelpParagraph) {
    return HelpParagraphView(item, theme);
  }
  return SizedBox.shrink();
}
