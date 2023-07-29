// write a main function that runs the widget test of FavoritePage.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:namer_app/favorites_page.dart';
import 'package:namer_app/generator_page.dart';
import 'package:namer_app/history_listview.dart';
import 'package:namer_app/model/word.dart';
import 'package:namer_app/random_word/bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:namer_app/random_word/event.dart';
import 'package:namer_app/repository/word_repository.dart';
import '../helper/bloc_observer.dart';
import '../helper/circular_words.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
@GenerateNiceMocks([MockSpec<RandomWordFactory>()])
import 'favorites_page_test.mocks.dart';

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

  group("History List Golden Tests", () {
    testGoldens("History list with different number of items", (tester) async {
      const words = [
        Word(text: "HelloWorld", isFavorite: false),
        Word(text: "TomorrowFun", isFavorite: true),
        Word(text: "RippleArc", isFavorite: false),
        Word(text: "RubberBaby", isFavorite: true),
        Word(text: "UniqueNewYork", isFavorite: true),
      ];
      final gb = GoldenBuilder.column(bgColor: Colors.white, wrap: frame)
        ..addScenario(
            '1 item',
            Center(
              child: SizedBox(
                  height: 200,
                  child: HistoryListView(
                    listKey: GlobalKey<AnimatedListState>(),
                    history: [words[0]],
                  )),
            ))
        ..addScenario(
            '5 items',
            Center(
              child: SizedBox(
                  height: 200,
                  child: HistoryListView(
                    listKey: GlobalKey<AnimatedListState>(),
                    history: words,
                  )),
            ))
        ..addTextScaleScenario(
            "5 items with larger font",
            Center(
                child: SizedBox(
                    height: 200,
                    child: HistoryListView(
                      listKey: GlobalKey<AnimatedListState>(),
                      history: words,
                    ))),
            textScaleFactor: 2);

      await tester.pumpWidgetBuilder(
        gb.build(),
        surfaceSize: const Size(200, 900),
      );

      await screenMatchesGolden(tester, 'history_list_items');
    });
  });

  group("Responsive layout of the generator page", () {
    when(mockRandomWordFactory.generateRandomWord()).thenAnswer((_) {
      return randomWords.next();
    });
    testGoldens("Five history words", (tester) async {
      await tester.pumpWidgetBuilder(createGeneratorPage());
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        if (i % 2 == 0) {
          await tester.tap(find.text('Like'));
          await tester.pumpAndSettle();
        }
      }
      await multiScreenGolden(
        tester,
        'generator_page_devices',
        devices: [
          Device.iphone11,
          Device.tabletLandscape,
          Device.tabletPortrait
        ],
        overrideGoldenHeight: 1000,
      );
    });
  });
}

Widget frame(Widget child) {
  return Theme(
      data: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(color: const Color(0xFF9E9E9E)),
        ),
        child: child,
      ));
}
