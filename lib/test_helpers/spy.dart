class Spy {
  List<List<dynamic>> _args = [];

  void one(dynamic arg) {
    _args.add([arg]);
  }

  void two(dynamic x, y) {
    _args.add([x, y]);
  }

  void three(dynamic x, y, z) {
    _args.add([x, y, z]);
  }

  void clear() {
    _args = [];
  }

  int get calls => _args.length;

  List<List<dynamic>> get args => _args;
}

bool Function(Spy) toBeCalledWith(dynamic args) {
  return (spy) {
    final listArgs = args is List ? args : [args];
    final succeeded = spy.args.where((l) => _myListEqual(l, listArgs)).isNotEmpty;
    if (!succeeded) {
      print("Expected to be called with $args but it was"
          " called with ${spy.args.join(", ")}"
          "\n (called ${spy.args.length} time(s))");
    }
    return succeeded;
  };
}

bool Function(Spy) toBeCalledTimes(int n) {
  return (spy) {
    if (spy.args.length == n) {
      return true;
    }
    print("Expected spy to be called $n time(s) but it was called ${spy.calls} time(s).");
    return false;
  };
}

bool _myListEqual(List<dynamic> a, List<dynamic> b) {
  if (a.length == b.length) {
    for (var i = 0; i < a.length; i++) {
      final aItem = a[i];
      final bItem = b[i];
      if (aItem is List && bItem is List) {
        if (!_myListEqual(aItem, bItem)) {
          return false;
        }
      } else if (aItem != bItem) {
        return false;
      }
      return true;
    }
  }
  return false;
}
