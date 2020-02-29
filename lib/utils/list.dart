T firstUnion<T>(List<T> listA, List<T> listB) {
  for (final x in listA) {
    if (listB.contains(x)) {
      return x;
    }
  }
  return null;
}
