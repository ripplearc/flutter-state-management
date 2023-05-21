import 'package:flutter_test/flutter_test.dart';
import 'package:namer_app/model/word.dart';
import 'package:namer_app/random_word/event.dart';
import 'package:namer_app/repository/word_repository.dart';

void main() {
  group("RandomWordEvent", () {
    final randomWordFactory = RandomWordFactoryImpl();
    final mockWord1 =
        Word(text: randomWordFactory.generateRandomWord(), isFavorite: false);
    final mockWord2 =
        Word(text: randomWordFactory.generateRandomWord(), isFavorite: true);
    group("GetNewWord", () {
      test("GetWord supports equality",
          () => expect(GetNewWord(), GetNewWord()));
    });

    group("ToggleFavorite", () {
      test(
          "given the same word, ToggleFavorite should be equal",
          () => expect(
              ToggleFavorite(mockWord1.text), ToggleFavorite(mockWord1.text)));
      test(
          "given different words, ToggleFavorite should not be equal",
          () => expect(ToggleFavorite(mockWord1.text),
              isNot(ToggleFavorite(mockWord2.text))));
    });

    group("RemoveFavorite", () {
      test(
          "given the same word, RemoveFavorite should be equal",
          () => expect(
              RemoveFavorite(mockWord1.text), RemoveFavorite(mockWord1.text)));

      test(
          "given different words, RemoveFavorite should not be equal",
          () => expect(RemoveFavorite(mockWord1.text),
              isNot(RemoveFavorite(mockWord2.text))));
    });
  });
}
