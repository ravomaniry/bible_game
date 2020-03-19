import 'package:bible_game/app/components/splash_screen.dart';
import 'package:bible_game/app/help/components/gallery/gallery.dart';
import 'package:bible_game/app/help/components/gallery/models.dart';
import 'package:bible_game/app/help/components/text/models.dart';
import 'package:bible_game/app/help/components/text/text.dart';
import 'package:bible_game/app/help/view_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Help extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext _, HelpViewModel viewModel) {
    if (viewModel.state.value == null) {
      return SplashScreen();
    }
    return ListView(
      key: Key("helpScreen"),
      children: [
        for (final item in viewModel.state.value)
          if (item is TextContent)
            HelpText(item, viewModel.theme, key: item.key)
          else if (item is GalleryContent)
            HelpGallery(item, viewModel.theme, key: item.key)
      ],
    );
  }
}
