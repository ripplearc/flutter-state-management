import 'package:flutter_test/flutter_test.dart';
import 'package:namer_app/model/word.dart';
import 'package:namer_app/random_word/state.dart';
import 'package:namer_app/repository/word_repository.dart';

void main() {
  group("RandomWordStateTest", () {
    final randomWordFactory = RandomWordFactoryImpl();
    group("HistoryUpdated", () {
      // test
      test("isFavorite is used in equality check", () {
        final mockWord1 = Word(
            text: randomWordFactory.generateRandomWord(), isFavorite: false);
        final mockWord2 = mockWord1.copyWith(isFavorite: true);
        final mockCurrent = Word(
            text: randomWordFactory.generateRandomWord(), isFavorite: false);

        expect(HistoryUpdated([mockWord1], mockCurrent),
            isNot(HistoryUpdated([mockWord2], mockCurrent)));
      });

      test("HistoryUpdated state supports equality", () {
        final mockHistory1 = [
          Word(text: randomWordFactory.generateRandomWord(), isFavorite: false),
          Word(text: randomWordFactory.generateRandomWord(), isFavorite: true)
        ];
        final mockHistory2 = [
          Word(text: randomWordFactory.generateRandomWord(), isFavorite: false),
          Word(text: randomWordFactory.generateRandomWord(), isFavorite: true)
        ];
        final mockCurrent1 = Word(
            text: randomWordFactory.generateRandomWord(), isFavorite: false);
        final mockCurrent2 = Word(
            text: randomWordFactory.generateRandomWord(), isFavorite: false);

        expect(HistoryUpdated(mockHistory1, mockCurrent1),
            HistoryUpdated(mockHistory1, mockCurrent1));
        expect(HistoryUpdated(mockHistory1, mockCurrent1),
            isNot(HistoryUpdated(mockHistory2, mockCurrent1)));
        expect(HistoryUpdated(mockHistory1, mockCurrent1),
            isNot(HistoryUpdated(mockHistory1, mockCurrent2)));
      });
    });
  });
}
