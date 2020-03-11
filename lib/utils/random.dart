import 'dart:math';

T getRandomElement<T>(List<T> list, Random rand) {
  return list[rand.nextInt(list.length)];
}
