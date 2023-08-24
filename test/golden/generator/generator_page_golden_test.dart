import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:namer_app/generator_page.dart';
import 'package:namer_app/history_listview.dart';
import 'package:namer_app/main.dart';
import 'package:namer_app/model/word.dart';
import 'package:namer_app/random_word/bloc.dart';
import 'package:namer_app/repository/word_repository.dart';

import '../../helper/circular_words.dart';
import '../flutter_test_config.dart';
@GenerateNiceMocks([MockSpec<RandomWordFactory>()])
import 'generator_page_golden_test.mocks.dart';

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
          home: MyHomePage(
              generatorPage: const GeneratorPage(), favoritesPage: Container()),
        ));
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
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: DevicePool.devices)
        ..addScenario(
          widget: createGeneratorPage(),
          name: 'Generate 5 words',
          onCreate: (scenarioWidgetKey) async {
            final nextFinder = find.descendant(
              of: find.byKey(scenarioWidgetKey),
              matching: find.text('Next'),
            );
            final likeFinder = find.descendant(
              of: find.byKey(scenarioWidgetKey),
              matching: find.text('Like'),
            );
            expect(nextFinder, findsOneWidget);
            for (var i = 0; i < 4; i++) {
              await tester.tap(nextFinder);
              await tester.pumpAndSettle();
              if (i % 2 == 0) {
                await tester.tap(likeFinder);
                await tester.pumpAndSettle();
              }
            }
          },
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'Generator page on multiple devices');
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
