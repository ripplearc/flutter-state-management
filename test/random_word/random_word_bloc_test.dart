import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:namer_app/model/Word.dart';
import 'package:namer_app/random_word/bloc.dart';
import 'package:namer_app/random_word/event.dart';
import 'package:namer_app/random_word/state.dart';
import 'package:namer_app/repository/WordRepository.dart';

import '../helper/circular_words.dart';
@GenerateNiceMocks([MockSpec<RandomWordFactory>()])
import 'random_word_bloc_test.mocks.dart';

void main() {
  final mockRandomWordFactory = MockRandomWordFactory();
  final randomWords = CircularWords();

  group("RandomWordBloc", () {
    when(mockRandomWordFactory.generateRandomWord())
        .thenAnswer((_) => randomWords.next());
    test(
        'given the initial state, should emit with a random word and empty history',
        () {
      randomWords.reset();
      expect(RandomWordBloc(mockRandomWordFactory).state,
          const HistoryUpdated([], Word(text: "test1", isFavorite: false)));
    });
    blocTest(
      "given a current word, then get the next random word, should add the previous one to the history",
      setUp: () => randomWords.reset(),
      build: () => RandomWordBloc(mockRandomWordFactory),
      act: (bloc) => bloc.add(GetNewWord()),
      expect: () => [
        const HistoryUpdated([Word(text: "test1", isFavorite: false)],
            Word(text: "test2", isFavorite: false))
      ],
    );
    blocTest(
      "given a current word, then ToggleFavorite of the current word, should update the favorite of current word",
      setUp: () => randomWords.reset(),
      build: () => RandomWordBloc(mockRandomWordFactory),
      act: (bloc) => bloc.add(ToggleFavorite("test1")),
      expect: () =>
          [const HistoryUpdated([], Word(text: "test1", isFavorite: true))],
    );
    blocTest(
      "given a history word, then ToggleFavorite of a history word, should update the favorite of the history word",
      setUp: () => randomWords.reset(),
      build: () => RandomWordBloc(mockRandomWordFactory),
      act: (bloc) {
        bloc.add(GetNewWord());
        bloc.add(ToggleFavorite("test1"));
      },
      expect: () => [
        const HistoryUpdated([Word(text: "test1", isFavorite: false)],
            Word(text: "test2", isFavorite: false)),
        const HistoryUpdated([Word(text: "test1", isFavorite: true)],
            Word(text: "test2", isFavorite: false))
      ],
    );
    blocTest(
      "given the current word of favorite, then RemoveFavorite of the current word, should update the favorite of current word",
      setUp: () => randomWords.reset(),
      build: () => RandomWordBloc(mockRandomWordFactory),
      act: (bloc) {
        bloc.add(ToggleFavorite("test1"));
        bloc.add(RemoveFavorite("test1"));
      },
      expect: () => [
        const HistoryUpdated([], Word(text: "test1", isFavorite: true)),
        const HistoryUpdated([], Word(text: "test1", isFavorite: false))
      ],
    );
    blocTest(
      "given a history word of favorite, then RemoveFavorite of a history word, should update the favorite of the history word",
      setUp: () => randomWords.reset(),
      build: () => RandomWordBloc(mockRandomWordFactory),
      act: (bloc) {
        bloc.add(GetNewWord());
        bloc.add(ToggleFavorite("test1"));
        bloc.add(RemoveFavorite("test1"));
      },
      expect: () => [
        const HistoryUpdated([Word(text: "test1", isFavorite: false)],
            Word(text: "test2", isFavorite: false)),
        const HistoryUpdated([Word(text: "test1", isFavorite: true)],
            Word(text: "test2", isFavorite: false)),
        const HistoryUpdated([Word(text: "test1", isFavorite: false)],
            Word(text: "test2", isFavorite: false))
      ],
    );
  });
}
