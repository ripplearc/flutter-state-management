import 'package:flutter_test/flutter_test.dart';
import 'package:namer_app/model/Word.dart';

void main() {
  group('WordTest', () {
    test('WordTest supports equality', () {
      expect(const Word(text: "test1", isFavorite: false),
          const Word(text: "test1", isFavorite: false));
      expect(const Word(text: "test1", isFavorite: false),
          isNot(const Word(text: "test2", isFavorite: false)));
      expect(const Word(text: "test1", isFavorite: false),
          isNot(const Word(text: "test1", isFavorite: true)));
    });
  });
}
