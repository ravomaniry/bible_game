class CalculatorState {
  String output = "";
  String operator = "";
  String mode = "";
  double a = 0;
  double b = 0;

  CalculatorState({
    this.output = "",
    this.operator = "",
    this.mode = "a",
    this.a = 0,
    this.b = 0,
  });

  CalculatorState copy() {
    return CalculatorState(
        output: output, operator: operator, mode: mode, a: a, b: b);
  }

  @override
  String toString() {
    return "output=$output operator=$operator mode=$mode a=$a b=$b";
  }
}
