import 'package:english_words/english_words.dart';

abstract class RandomWordFactory {
  String generateRandomWord();
}

class RandomWordFactoryImpl extends RandomWordFactory {
  @override
  String generateRandomWord() {
    final wordPair = WordPair.random();
    return wordPair.asLowerCase;
  }
}
