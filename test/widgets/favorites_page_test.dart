// write a main function that runs the widget test of FavoritePage.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:namer_app/FavoritesPage.dart';
import 'package:namer_app/random_word/bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:namer_app/random_word/event.dart';
import 'package:namer_app/repository/WordRepository.dart';
import '../helper/circular_words.dart';
@GenerateNiceMocks([MockSpec<RandomWordFactory>()])
import 'favorites_page_test.mocks.dart';

// create  a BlocObserver to override onChange
class TestBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    print('${bloc.runtimeType} $change 😀😀😀');
    super.onChange(bloc, change);
  }
}

void main() {
  final mockRandomWordFactory = MockRandomWordFactory();
  final randomWords = CircularWords();
  Bloc.observer = TestBlocObserver();
  void setupCircularWords() {
    randomWords.reset();
    when(mockRandomWordFactory.generateRandomWord()).thenAnswer((_) {
      return randomWords.next();
    });
  }

  setUp(() {
    setupCircularWords();
  });

  Widget createFavoritePage(
      RandomWordBloc bloc, GlobalKey<AnimatedListState> animatedListKey) {
    return MaterialApp(
        title: "Namer App",
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
        home: BlocProvider(
          create: (_) => bloc,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Favorites'),
            ),
            body: FavoritesPage(listKey: animatedListKey),
          ),
        ));
  }

  // create group
  group("FavoritePage", () {
    testWidgets(
        "given first loading the favorite page, should display no favorite",
        (tester) async {
      final bloc = RandomWordBloc(mockRandomWordFactory);
      final animatedListKey = GlobalKey<AnimatedListState>();
      await tester.pumpWidget(createFavoritePage(bloc, animatedListKey));
      await tester.pump();
      expect(find.text("You have 0 favorites"), findsOneWidget);
    });
    testWidgets(
        "given first loading the favorite page, then add a word to favorite, should display the word in favorite",
        (tester) async {
      final bloc = RandomWordBloc(mockRandomWordFactory);
      final animatedListKey = GlobalKey<AnimatedListState>();

      await tester.pumpWidget(createFavoritePage(bloc, animatedListKey));
      await tester.pumpAndSettle();
      bloc.add(ToggleFavorite("test1"));
      animatedListKey.currentState?.insertItem(0);
      await tester.pumpAndSettle();
      bloc.add(GetNewWord());
      bloc.add(ToggleFavorite("test2"));
      animatedListKey.currentState?.insertItem(0);
      await tester.pumpAndSettle();
      expect(find.text("You have 2 favorites"), findsOneWidget);
      final animatedListWidget =
          tester.widget<AnimatedList>(find.byType(AnimatedList));
      expect(animatedListWidget.initialItemCount, 2);
      final listTileFinder = find.descendant(
          of: find.byType(AnimatedList), matching: find.byType(ListTile));
      expect(listTileFinder, findsNWidgets(2));
    });
    // given 2 favorite words, then remove one of them, should have one favorite word left
    testWidgets(
        "given 2 favorite words, then remove one of them, should have one favorite word left",
        (tester) async {
      final bloc = RandomWordBloc(mockRandomWordFactory);
      final animatedListKey = GlobalKey<AnimatedListState>();

      await tester.pumpWidget(createFavoritePage(bloc, animatedListKey));
      await tester.pumpAndSettle();
      bloc.add(GetNewWord());
      bloc.add(ToggleFavorite("test1"));
      animatedListKey.currentState?.insertItem(0);
      await tester.pumpAndSettle();
      bloc.add(ToggleFavorite("test2"));
      animatedListKey.currentState?.insertItem(0);
      await tester.pumpAndSettle();
      expect(find.text("You have 2 favorites"), findsOneWidget);

      // remove test1
      bloc.add(ToggleFavorite("test1"));
      animatedListKey.currentState?.removeItem(
          1, (context, animation) => Container(),
          duration: Duration.zero);
      await tester.pumpAndSettle();

      expect(find.text("You have 1 favorites"), findsOneWidget);
      final listTileFinder = find.descendant(
          of: find.byType(AnimatedList), matching: find.byType(ListTile));
      expect(listTileFinder, findsOneWidget);
    });
  });
}
