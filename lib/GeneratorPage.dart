import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/HistoryListView.dart';

class GeneratorPage extends StatefulWidget {
  const GeneratorPage(
      {super.key,
      required this.pair,
      required this.getNextWord,
      required this.toggleFavorites,
      required this.isFavorite,
      required this.favorites,
      required this.history});

  final List<WordPair> history;
  final WordPair pair;
  final void Function(AnimatedListState?) getNextWord;
  final VoidCallback toggleFavorites;
  final List<WordPair> favorites;
  final bool Function(WordPair) isFavorite;

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: HistoryListView(
            history: widget.history,
            isFavorite: widget.isFavorite,
            listKey: listKey,
          ),
        ),
        const Text("A random idea:"),
        WordCard(pair: widget.pair),
        const SizedBox(height: 10),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FavoriteButton(
                pair: widget.pair,
                isFavorite: widget.isFavorite,
                toggleFavorites: () {
                  widget.toggleFavorites();
                },
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                  onPressed: () {
                    widget.getNextWord(listKey.currentState);
                  },
                  child: const Text("Next")),
            ],
          ),
        ),
        const Expanded(
          flex: 2,
          child: SizedBox(),
        )
      ],
    );
  }
}

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.pair,
    required this.toggleFavorites,
    required this.isFavorite,
  });

  final WordPair pair;
  final VoidCallback toggleFavorites;
  final bool Function(WordPair) isFavorite;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<MyAppState>();
    // var favorites = appState.favorites;
    // var pair = appState.current;
    return ElevatedButton.icon(
        onPressed: () {
          setState(() {
            widget.toggleFavorites();
          });
        },
        icon: widget.isFavorite(widget.pair)
            ? const Icon(Icons.favorite)
            : const Icon(Icons.favorite_border),
        label: const Text(
          'Like',
        ));
  }
}

class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium
        ?.copyWith(color: theme.colorScheme.onPrimary);
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
