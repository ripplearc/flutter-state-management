import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namer_app/model/Word.dart';
import 'package:namer_app/random_word/bloc.dart';
import 'package:namer_app/random_word/event.dart';
import 'package:namer_app/random_word/state.dart';

/// A widget that displays a list of favorite words and allows the user to remove them.
///
/// The list of favorite words is obtained from the [RandomWordState.favorites].
/// The list is displayed using an [AnimatedList].
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, required this.listKey});

  final GlobalKey<AnimatedListState> listKey;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RandomWordBloc, RandomWordState>(
        builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16.0),
            child: Text("You have ${state.favorites.length} favorites"),
          ),
          Expanded(
            child: AnimatedList(
              key: widget.listKey,
              initialItemCount: state.favorites.length,
              itemBuilder: (context, index, animation) {
                final word = state.favorites[index];
                return _buildItem(
                  index,
                  word,
                  animation,
                  () => _removeItem(index, word, context),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildItem(int index, Word word, Animation<double> animation,
          VoidCallback? onPressed) =>
      SizeTransition(
        sizeFactor: animation,
        child: ListTile(
          title: Text(word.text),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onPressed,
          ),
        ),
      );

  void _removeItem(
    int index,
    Word word,
    BuildContext context,
  ) {
    context.read<RandomWordBloc>().add(RemoveFavorite(word.text));
    widget.listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItem(index, word, animation, null),
      duration: const Duration(milliseconds: 200),
    );
  }
}
