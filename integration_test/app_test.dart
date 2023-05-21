import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:namer_app/generator_page.dart';

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

  setUp(() async {
    randomWords.reset();
  });

  group('end-to-end test', () {
    when(mockRandomWordFactory.generateRandomWord()).thenAnswer((_) {
      return randomWords.next();
    });
    testWidgets('''given a history word, toggle its favorite, 
        and go to the favorites page to delete its favorite ''',
        (tester) async {
      // Arrange: Pump the generator page
      runAppUnderTest();
      await tester.pumpAndSettle();

      // Act: Add the word to the history and toggle the favorite status
      await tester.tap(find.text("Next"));
      await tester.pumpAndSettle();
      // Act: Tap the TextButton that has text "test1"
      await tester.tap(find.widgetWithText(SizeTransition, "test1"));
      await tester.pump();

      // Assert: should see the word with favorite icon in the history
      final icon = find.descendant(
          of: find.byType(AnimatedList), matching: find.byIcon(Icons.favorite));
      expect(icon, findsOneWidget);

      // Act: Tap the favorite button to toggle the favorite status
      await tester.tap(icon);
      await tester.pump();
      // Assert: should see the word being unfavorited
      final noIcon = find.descendant(
          of: find.byType(AnimatedList), matching: find.byIcon(Icons.favorite));
      expect(noIcon, findsNothing);

      // Act: Tap the word of "test1", and go to the favorites page
      await tester.tap(find.widgetWithText(SizeTransition, "test1"));
      await tester.pump();
      await tester.tap(find.text("Favorites"));
      await tester.pumpAndSettle();

      // Assert: should see the word in the faovrites page
      expect(find.text("test1"), findsOneWidget);

      // Act: Tap the delete button, and then go back to the generator page
      await tester.tap(find.byIcon(Icons.delete));
      await tester.tap(find.text("Home"));
      await tester.pumpAndSettle();

      // Assert: should see the word being unfavorited on the generator page
      final noIcon2 = find.descendant(
          of: find.byType(AnimatedList), matching: find.byIcon(Icons.favorite));
      expect(noIcon2, findsNothing);
    });

    testWidgets("""given the current word is favorited, 
        then go to the favorites page to delete it, 
        should see the current word being unfavorited on the generator page""",
        (tester) async {
      // Arrange: Pump the generator page
      runAppUnderTest();
      await tester.pumpAndSettle();

      // Act: Tap the favorite button
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();
      // Assert: should see the word being favorited
      expect(
          find.widgetWithIcon(FavoriteButton, Icons.favorite), findsOneWidget);

      // Act: Go to the favorites page, tap the delete button, and then go back to the generator page
      await tester.tap(find.text("Favorites"));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.tap(find.text("Home"));
      await tester.pump();

      // Assert: should see the current word being unfavorited on the generator page
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });
  });
}
