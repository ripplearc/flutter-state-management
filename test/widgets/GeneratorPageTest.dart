// write a widget test for the GenerateScreen widget
// Path: test/widgets/GeneratorPageTest.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:namer_app/GeneratorPage.dart';
import 'package:namer_app/random_word/bloc.dart';
import 'package:namer_app/repository/WordRepository.dart';

import '../helper/CircularWords.dart';
@GenerateNiceMocks([MockSpec<RandomWordFactory>()])
import 'GeneratorPageTest.mocks.dart';

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
      // pump widget from createGeneratePage()
      await tester.pumpWidget(createGeneratorPage());
      await tester.pump();
      // first random word should be "test1"
      expect(find.text("test1"), findsOneWidget);
      // no history should be displayed
      final animatedListWidget =
          tester.widget<AnimatedList>(find.byType(AnimatedList));
      expect(animatedListWidget.initialItemCount, 0);
    });
    testWidgets(
        "given first loading the generator page, then get a new word, should display a new random word",
        (tester) async {
      await tester.pumpWidget(createGeneratorPage());
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      // second random word should be "test2"
      expect(find.text("test2"), findsOneWidget);
      // verify one history item is displayed
      final parent = find.ancestor(
          of: find.text('test1'), matching: find.byType(AnimatedList));
      expect(parent, findsOneWidget);
    });
    testWidgets(
        "given current word, then favorite the current, should show icon with solid favorite",
        (tester) async {
      await tester.pumpWidget(createGeneratorPage());
      await tester.pump();

      final favoriteIcon = find.byWidgetPredicate((w) {
        return w is Icon && w.icon == Icons.favorite_border;
      });
      expect(favoriteIcon, findsOneWidget);
      await tester.tap(favoriteIcon);

      await tester.pump();
      // favorite the current word
      final alreadyFavoritesIcon = find.byWidgetPredicate((w) {
        return w is Icon && w.icon == Icons.favorite;
      });
      expect(alreadyFavoritesIcon, findsOneWidget);
    });
    testWidgets(
        "given current word, then favorite the current and add new word, should show the history word with favorite icon",
        (tester) async {
      await tester.pumpWidget(createGeneratorPage());
      await tester.pump();

      final favoriteIcon = find.byWidgetPredicate((w) {
        return w is Icon && w.icon == Icons.favorite_border;
      });
      expect(favoriteIcon, findsOneWidget);
      await tester.tap(favoriteIcon);
      await tester.tap(find.text("Next"));
      await tester.pumpAndSettle();

      // should display the history word with favorite icon
      final parent = find.ancestor(
          of: find.byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.favorite),
          matching: find.byType(AnimatedList));
      expect(parent, findsOneWidget);
    });
    testWidgets(
        "given favorite current word, then add new word and then toggle off favorite of the history word, should remove the favorite icon of the history word",
        (tester) async {
      await tester.pumpWidget(createGeneratorPage());
      await tester.pump();

      final favoriteBorderIcon = find.byWidgetPredicate((w) {
        return w is Icon && w.icon == Icons.favorite_border;
      });
      expect(favoriteBorderIcon, findsOneWidget);
      await tester.tap(favoriteBorderIcon);
      await tester.tap(find.text("Next"));
      await tester.pumpAndSettle();

      // tap the favorite icon of the history word
      final favoriteIcon = find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.favorite);
      await tester.tap(favoriteIcon);
      await tester.pump();

      // should remove the favorite icon of the history word
      final parent = find.ancestor(
          of: find.byWidgetPredicate(
                  (widget) => widget is Icon && widget.icon == Icons.favorite),
          matching: find.byType(AnimatedList));
      expect(parent, findsNothing);
    });
    testWidgets(
        "given current word, then add new word and then toggle on favorite of the history word, should add the favorite icon of the history word",
        (tester) async {
      await tester.pumpWidget(createGeneratorPage());
      await tester.pump();

      await tester.tap(find.text("Next"));
      await tester.pumpAndSettle();

      // tap the history word
      final historyWord = find.text("test1");
      await tester.tap(historyWord);
      await tester.pump();

      // should add the favorite icon of the history word
      final parent = find.ancestor(
          of: find.byWidgetPredicate(
                  (widget) => widget is Icon && widget.icon == Icons.favorite),
          matching: find.byType(AnimatedList));
      expect(parent, findsOneWidget);
    });
  });
}
