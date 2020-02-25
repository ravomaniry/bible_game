bool Function(List) toBeAll1(value) {
  return (tested) {
    for (var x = 0; x < tested.length; x++) {
      final item = tested[x];
      if (item != value) {
        print("Expected all to be equals to $value but found $item at position [$x]");
        return false;
      }
    }
    return true;
  };
}

bool Function(List<List>) toBeAll2(value) {
  return (tested) {
    for (var y = 0; y < tested.length; y++) {
      final row = tested[y];
      for (var x = 0; x < row.length; x++) {
        final item = row[x];
        if (item != value) {
          print("Expected all to be equals to $value but found $item at position [$y][$x]");
          return false;
        }
      }
    }
    return true;
  };
}

bool Function(List) toHave1(value, number) {
  return (tested) {
    final count = tested.where((item) => item == number).length;
    if (count == number) {
      return true;
    }
    print("Expected to have $number $value but found $count");
    return false;
  };
}

bool Function(List<List>) toHave2(value, number) {
  return (tested) {
    var count = 0;
    for (final row in tested) {
      count += row.where((item) => item == value).length;
    }
    if (count == number) {
      return true;
    }
    print("Expected to have $number '$value' but found $count");
    return false;
  };
}
