import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/FavoritesPage.dart';
import 'package:provider/provider.dart';

import 'GeneratorPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => RandomWordsProvider(),
        child: MaterialApp(
          title: "Namer App",
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
          home: MyHomePage(),
        ));
  }
}

class RandomWordsProvider extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var history = <WordPair>[];

  void toggleFavorites() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair word) {
    favorites.remove(word);
    notifyListeners();
  }

  void getNext(AnimatedListState? state) {
    current = WordPair.random();
    history.insert(0, current);
    state?.insertItem(0);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = const FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text("Home"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text("Favorites"),
                  ),
                ],
                selectedIndex: selectedIndex,
                extended: constraints.maxWidth >= 600,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
              Expanded(
                child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: page),
              ),
            ],
          ),
        ),
      );
    });
  }
}
