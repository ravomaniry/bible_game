import 'package:bible_game/redux/calculator/state.dart';

CalculatorState handleInput(CalculatorState state, String value) {
  state = state.copy();
  final output = state.output;
  final mode = state.mode;

  if (["/", "*", "-", "+"].contains(value)) {
    if (mode == "a") {
      state.a = _checkNumber(output);
      state.output = "";
      state.mode = "op";
      state.operator = value;
    } else if (mode == "op") {
      state.operator = value;
    } else {
      state.b = _checkNumber(output);
      _computeOutput(state);
      state.operator = value;
      state.mode = "op";
    }
  } else if (value == 'CLEAR') {
    state.output = "";
    _resetCalculus(state);
  } else if (value == "DEL") {
    if ((mode == "a") || (mode == "b") && output.length > 0) {
      state.output = output.substring(0, output.length - 1);
    }
  } else if (value == "=") {
    if (mode == "a") {
      state.output = _checkNumber(output).toString();
    } else if (mode == "op") {
      state.b = 0;
      _computeOutput(state);
      _resetCalculus(state);
    } else {
      state.b = _checkNumber(output);
      _computeOutput(state);
      _resetCalculus(state);
    }
  } else {
    if (mode == "op") {
      state.mode = "b";
      state.output = value;
    } else {
      state.output += value;
    }
  }
  return state;
}

void _computeOutput(CalculatorState state) {
  final a = state.a;
  final b = state.b;
  var result = state.a;
  switch (state.operator) {
    case "/":
      result = a / b;
      break;
    case "*":
      result = a * b;
      break;
    case "+":
      result = a + b;
      break;
    case "-":
      result = a - b;
      break;
  }
  state.output = result.toString();
  state.a = result;
  state.b = null;
}

double _checkNumber(String str) {
  try {
    return double.parse(str);
  } catch (e) {
    return 0;
  }
}

void _resetCalculus(CalculatorState state) {
  state.mode = "a";
  state.a = 0;
  state.b = 0;
  state.operator = "";
}
