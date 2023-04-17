import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.removeFavorite,
  });

  final void Function(WordPair) removeFavorite;
  final List<WordPair> favorites;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 16.0),
          child: Text("You have ${widget.favorites.length} favorites"),
        ),
        Expanded(
          child: AnimatedList(
            key: _listKey,
            initialItemCount: widget.favorites.length,
            itemBuilder: (context, index, animation) {
              final word = widget.favorites[index];
              return _buildItem(
                index,
                word,
                animation,
                () => _removeItem(index, word),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItem(int index, WordPair word, Animation<double> animation,
          VoidCallback? onPressed) =>
      SizeTransition(
        sizeFactor: animation,
        child: ListTile(
          title: Text(word.asLowerCase),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onPressed,
          ),
        ),
      );

  void _removeItem(int index, WordPair word) {
    widget.removeFavorite(word);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItem(index, word, animation, null),
      duration: const Duration(milliseconds: 200),
    );
  }
}
