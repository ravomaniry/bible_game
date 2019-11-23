class AppState {
  String output = "";
  String operator = "";
  String mode = "";
  double a = 0;
  double b = 0;

  AppState({this.output, this.operator, this.mode, this.a, this.b});

  AppState copy() {
    return AppState(output: output, operator: operator, mode: mode, a: a, b: b);
  }

  void handleInput(String value) {
    if (["/", "*", "-", "+"].contains(value)) {
      if (mode == "a") {
        a = _checkNumber(output);
        output = "";
        mode = "op";
        operator = value;
      } else if (mode == "op") {
        operator = value;
      } else {
        b = _checkNumber(output);
        computeOutput();
        operator = value;
        mode = "op";
      }
    } else if (value == 'CLEAR') {
      output = "";
      _resetCalculus();
    } else if (value == "DEL") {
      if ((mode == "a") || (mode == "b") && output.length > 0) {
        output = output.substring(0, output.length - 1);
      }
    } else if (value == "=") {
      if (mode == "a") {
        output = _checkNumber(output).toString();
      } else if (mode == "op") {
        b = 0;
        computeOutput();
        _resetCalculus();
      } else {
        b = _checkNumber(output);
        computeOutput();
        _resetCalculus();
      }
    } else {
      if (mode == "op") {
        mode = "b";
        output = value;
      } else {
        output += value;
      }
    }
  }

  void computeOutput() {
    var result = a;
    switch (operator) {
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
    output = result.toString();
    a = result;
    b = null;
  }

  double _checkNumber(String str) {
    try {
      return double.parse(str);
    } catch (e) {
      return 0;
    }
  }

  void _resetCalculus() {
    mode = "a";
    a = 0;
    b = 0;
    operator = "";
  }
}
