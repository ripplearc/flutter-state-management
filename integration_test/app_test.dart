import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:namer_app/main.dart' as app;
import 'package:namer_app/main.dart';
import 'package:namer_app/random_word/bloc.dart';
import 'package:namer_app/repository/word_repository.dart';

import '../test/helper/circular_words.dart';
@GenerateNiceMocks([MockSpec<RandomWordFactory>()])
import 'app_test.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final mockRandomWordFactory = MockRandomWordFactory();
  final randomWords = CircularWords();

  void runAppUnderTest() {
    return runApp(BlocProvider(
        create: (_) => RandomWordBloc(mockRandomWordFactory),
        child: MaterialApp(
          title: "Namer App",
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
          home: const MyHomePage(),
        )));
  }

  group('end-to-end test', () {
    when(mockRandomWordFactory.generateRandomWord()).thenAnswer((_) {
      return randomWords.next();
    });
    testWidgets(
        '''given the current word, then tap the favorite button and add a new word, 
        should see the word with favorite icon in the history''',
        (tester) async {
          // Arrange: Pump the generator page
      runAppUnderTest();
      await tester.pumpAndSettle();

      // Act: Tap the favorite button and add a new word
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.tap(find.text("Next"));


      // Assert: First random word should be "test1"
      expect(find.text("test1"), findsOneWidget);
      // Assert: No history should be displayed
      final animatedListWidget =
          tester.widget<AnimatedList>(find.byType(AnimatedList));
      expect(animatedListWidget.initialItemCount, 0);
    });
  });
}
