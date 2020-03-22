import 'package:animator/animator.dart';
import 'package:bible_game/app/splash_screen/oscillator.dart';
import 'package:bible_game/app/splash_screen/view_model.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, SplashScreenViewModel viewModel) {
    return Scaffold(
      key: Key("loader"),
      body: Center(
        child: SplashScreenBody(
          viewModel.theme,
          dbStatus: viewModel.dbStatus,
        ),
      ),
    );
  }
}

class SplashScreenBody extends StatelessWidget {
  final AppColorTheme theme;
  final double dbStatus;

  SplashScreenBody(this.theme, {this.dbStatus = 0});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WordsOscillator(theme),
        _BarAnimator(theme),
        _DbStatus(theme, dbStatus),
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

class _DbStatus extends StatelessWidget {
  final AppColorTheme _theme;
  final double _dbStatus;

  _DbStatus(this._theme, this._dbStatus);

  @override
  Widget build(BuildContext context) {
    if (_dbStatus > 0 && _dbStatus < 100) {
      return Text(
        (_dbStatus * 100).toStringAsFixed(1),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _theme.primary,
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
