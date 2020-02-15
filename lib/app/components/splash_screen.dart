import 'package:animator/animator.dart';
import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/components/oscillator.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

AppColorTheme _converter(Store<AppState> store) => store.state.theme;

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: _converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, AppColorTheme theme) {
    return Scaffold(
      key: Key("loader"),
      body: Center(
        child: SplashScreenBody(theme),
      ),
    );
  }
}

class SplashScreenBody extends StatelessWidget {
  final AppColorTheme _theme;

  SplashScreenBody(this._theme);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WordsOscillator(_theme),
        _BarAnimator(_theme),
      ],
    );
  }
}

class _BarAnimator extends StatelessWidget {
  final AppColorTheme _theme;

  _BarAnimator(this._theme);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Animator(
      duration: const Duration(seconds: 1),
      repeats: -1,
      builder: (Animation anim) => _Bar(
        anim.value > 0.5 ? _theme.primary : _theme.accentLeft,
        (0.5 - anim.value).abs() * screenWidth,
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double _width;
  final Color _color;

  _Bar(this._color, this._width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: 10,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
    );
  }
}
