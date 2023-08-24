/// A helper class to generate a circular list of random words
class CircularWords {
  final words = [
    "test1",
    "test2",
    "test3",
    "briefstance",
    "beastscent",
    "DetroitBecomeHuman"
  ];
  int count = 0;

  String next() {
    if (count == words.length) count = 0;
    final word = words[count];
    count++;
    return word;
  }

  void reset() => count = 0;
}
