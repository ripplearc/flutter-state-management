import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namer_app/HistoryListView.dart';
import 'package:namer_app/random_word/bloc.dart';
import 'package:namer_app/random_word/event.dart';
import 'package:namer_app/random_word/state.dart';

/// A stateful widget that represents the page where the user can generate a new
/// random word. Every time a new random word is generated, the previous one is
/// added to the history list. The user can also favorite a word or undo it.
class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RandomWordBloc, RandomWordState>(
        buildWhen: (prev, state) => state is HistoryUpdated,
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: HistoryListView(
                  history: state.history,
                  listKey: listKey,
                ),
              ),
              const Text("A random idea:"),
              WordCard(pair: state.current.text),
              const SizedBox(height: 10),
              _buildButtons(context),
              const Expanded(flex: 2, child: SizedBox())
            ],
          );
        });
  }

  Center _buildButtons(BuildContext context) => Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFavoriteButton(),
            const SizedBox(width: 20),
            _buildGetNextButton(context),
          ],
        ),
      );

  ElevatedButton _buildGetNextButton(BuildContext context) => ElevatedButton(
      onPressed: () {
        context.read<RandomWordBloc>().add(GetNewWord());
        listKey.currentState?.insertItem(0);
      },
      child: const Text("Next"));

  Widget _buildFavoriteButton() =>
      BlocBuilder<RandomWordBloc, RandomWordState>(builder: (context, state) {
        return FavoriteButton(
            isFavorite: state.current.isFavorite,
            onPress: () {
              context.read<RandomWordBloc>().add(ToggleFavorite(state.current));
            });
      });
}

/// A favorite button that can add or remove the [RandomWordState.current]
/// random word from the user's [RandomWordState.favorites].
class FavoriteButton extends StatelessWidget {
  const FavoriteButton(
      {super.key, required this.onPress, required this.isFavorite});

  final VoidCallback onPress;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: onPress,
        icon: isFavorite
            ? const Icon(Icons.favorite)
            : const Icon(Icons.favorite_border),
        label: const Text(
          'Like',
        ));
  }
}

/// A StatelessWidget that displays a Card containing the current random word.
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
