import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namer_app/favorites_page.dart';
import 'package:namer_app/random_word/bloc.dart';
import 'package:namer_app/repository/word_repository.dart';

import 'generator_page.dart';

void main() {
  setupApp();
}

void setupApp() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => RandomWordBloc(RandomWordFactoryImpl()),
        child: MaterialApp(
            title: "Namer App",
            theme: ThemeData(
                useMaterial3: true,
                colorScheme:
                    ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
            home: MyHomePage(
                generatorPage: const GeneratorPage(),
                favoritesPage:
                    FavoritesPage(listKey: GlobalKey<AnimatedListState>()))));
  }
}

enum SelectedPageIndex {
  generator,
  favorites,
}

class MyHomePage extends StatefulWidget {
  final Widget generatorPage;
  final Widget favoritesPage;

  const MyHomePage(
      {Key? key, required this.generatorPage, required this.favoritesPage})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SelectedPageIndex selectedPageIndex = SelectedPageIndex.generator;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedPageIndex) {
      case SelectedPageIndex.generator:
        page = widget.generatorPage;
        break;
      case SelectedPageIndex.favorites:
        page = widget.favoritesPage; // Use the injected FavoritesPage instance
        break;
    }
    return Scaffold(body: encloseSafeArea(context, page));
  }

  SafeArea encloseSafeArea(BuildContext context, Widget page) => SafeArea(
      child: LayoutBuilder(
          builder: (context, constraints) =>
              contentInsideSafeArea(constraints, context, page)));

  Row contentInsideSafeArea(
      BoxConstraints constraints, BuildContext context, Widget page) {
    return Row(
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
          selectedIndex: selectedPageIndex.index,
          extended: constraints.maxWidth >= 600,
          onDestinationSelected: (value) {
            setState(() {
              selectedPageIndex = SelectedPageIndex.values[value];
            });
          },
        ),
        Expanded(
          child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page),
        ),
      ],
    );
  }
}
