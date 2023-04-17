import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/main.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<RandomWordsProvider>(
        builder: (context, provider, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                  child:
                      Text("You have ${provider.favorites.length} favorites"),
                ),
                Expanded(
                  child: AnimatedList(
                    key: _listKey,
                    initialItemCount: provider.favorites.length,
                    itemBuilder: (context, index, animation) {
                      final word = provider.favorites[index];
                      return _buildItem(
                        index,
                        word,
                        animation,
                        () => _removeItem(index, word, provider.removeFavorite),
                      );
                    },
                  ),
                ),
              ],
            ));
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

  void _removeItem(
    int index,
    WordPair word,
    Function(WordPair) removeFavorite,
  ) {
    removeFavorite(word);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItem(index, word, animation, null),
      duration: const Duration(milliseconds: 200),
    );
  }
}
