// write a widget test for the GenerateScreen widget
// Path: test/widgets/generator_page_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:namer_app/generator_page.dart';
import 'package:namer_app/random_word/bloc.dart';
import 'package:namer_app/repository/word_repository.dart';

import '../helper/circular_words.dart';
@GenerateNiceMocks([MockSpec<RandomWordFactory>()])
import 'generator_page_test.mocks.dart';

void main() {
  final mockRandomWordFactory = MockRandomWordFactory();
  final randomWords = CircularWords();

  Widget createGeneratorPage() {
    return BlocProvider(
      create: (_) => RandomWordBloc(mockRandomWordFactory),
      child: MaterialApp(
        title: "Namer App",
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
        home: const GeneratorPage(),
      ),
    );
  }

  setUp(() {
    randomWords.reset();
  });

  group("GeneratorPage", () {
    when(mockRandomWordFactory.generateRandomWord()).thenAnswer((_) {
      return randomWords.next();
    });
    testWidgets(
        "given first loading the generator page, should display a random word",
            (tester) async {
          // Arrange: Pump the generator page
          await tester.pumpWidget(createGeneratorPage());
          // Act: Render the page
          await tester.pump();
          // Assert: First random word should be "test1"
          expect(find.text("test1"), findsOneWidget);
          // Assert: No history should be displayed
          final animatedListWidget =
          tester.widget<AnimatedList>(find.byType(AnimatedList));
          expect(animatedListWidget.initialItemCount, 0);
        });
    testWidgets(
        "given first loading the generator page, then get a new word, should display a new random word",
            (tester) async {
          // Arrange: Pump the generator page
          await tester.pumpWidget(createGeneratorPage());
          await tester.pump();
          // Act: Get a new word
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
          // Assert: Second random word should be "test2"
          expect(find.text("test2"), findsOneWidget);
          // Assert: Verify displaying one history item
          final parent = find.ancestor(
              of: find.text('test1'), matching: find.byType(AnimatedList));
          expect(parent, findsOneWidget);
        });
    testWidgets(
        "given current word, then favorite the current, should show icon with solid favorite",
            (tester) async {
          // Arrange: Pump the generator page
          await tester.pumpWidget(createGeneratorPage());
          await tester.pump();
          final borderFavoriteIcon =
          find.widgetWithIcon(FavoriteButton, Icons.favorite_border);
          expect(borderFavoriteIcon, findsOneWidget);
          // Act: Favorite the current word
          await tester.tap(borderFavoriteIcon);
          await tester.pump();
          // Assert: The favorite button's icon changes to solid
          final solidFavoritesIcon = find.widgetWithIcon(
              FavoriteButton, Icons.favorite);
          expect(solidFavoritesIcon, findsOneWidget);
        });
    testWidgets(
        "given current word, then favorite the current and add new word, should show the history word with favorite icon",
            (tester) async {
          // Arrange: Pump the generator page
          await tester.pumpWidget(createGeneratorPage());
          await tester.pump();

          final favoriteIcon = find.widgetWithIcon(
              FavoriteButton, Icons.favorite_border);
          expect(favoriteIcon, findsOneWidget);
          // Act: Favorite the current word, add new word
          await tester.tap(favoriteIcon);
          await tester.tap(find.text("Next"));
          await tester.pumpAndSettle();

          // Assert: The history word should have favorite icon
          final icons = find.descendant(
              of: find.byType(AnimatedList),
              matching: find.byIcon(Icons.favorite));
          expect(icons, findsOneWidget);
        });
    testWidgets(
        "given favorite current word, then add new word and then toggle off favorite of the history word, should remove the favorite icon of the history word",
            (tester) async {
          // Arrange: Pump the generator page
          await tester.pumpWidget(createGeneratorPage());
          await tester.pump();

          final favoriteBorderIcon = find.widgetWithIcon(
              FavoriteButton, Icons.favorite_border);
          expect(favoriteBorderIcon, findsOneWidget);
          // Act: Favorite the current word, add new word, and tap the history word
          await tester.tap(favoriteBorderIcon);
          await tester.tap(find.text("Next"));
          await tester.pumpAndSettle();

          final favoriteIcon = find.widgetWithIcon(SizeTransition, Icons.favorite);
          await tester.tap(favoriteIcon);
          await tester.pump();

          // Assert: The history word should not have favorite icon
          final icons = find.descendant(
              of: find.byType(AnimatedList),
              matching: find.byIcon(Icons.favorite));
          expect(icons, findsNothing);
        });
    testWidgets(
        "given current word, then add new word and then toggle on favorite of the history word, should add the favorite icon of the history word",
            (tester) async {
          // Arrange: Pump the generator page
          await tester.pumpWidget(createGeneratorPage());
          await tester.pump();

          // Act: Add new word, tap the history word
          await tester.tap(find.text("Next"));
          await tester.pumpAndSettle();
          expect(find.text("test2"), findsOneWidget);

          final historyWord = find.text("test1");
          await tester.tap(historyWord);
          await tester.pump();

          // Assert: The history word should have favorite icon
          final icons = find.descendant(
              of: find.byType(AnimatedList),
              matching: find.byIcon(Icons.favorite));
          expect(icons, findsOneWidget);
        });
  });
}
