T firstUnion<T>(List<T> listA, List<T> listB) {
  for (final x in listA) {
    if (listB.contains(x)) {
      return x;
    }
  }
  return null;
}

bool haveInCommon(List a, List b) {
  for (final item in a) {
    if (b.contains(item)) {
      return true;
    }
  }
  return false;
}
