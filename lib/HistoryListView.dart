import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

class HistoryListView extends StatefulWidget {
  const HistoryListView({
    super.key,
    required this.history,
    required this.isFavorite,
    required this.listKey,
  });

  final List<WordPair> history;
  final bool Function(WordPair) isFavorite;
  final GlobalKey<AnimatedListState> listKey;

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {

  static const Gradient _maskingGradient = LinearGradient(
      colors: [Colors.transparent, Colors.black],
      stops: [0.0, 0.5],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
          key: widget.listKey,
          reverse: true,
          initialItemCount: widget.history.length,
          itemBuilder: (context, index, animation) {
            final pair = widget.history[index];
            return SizeTransition(
              sizeFactor: animation,
              child: Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: widget.isFavorite(pair)
                      ? const Icon(Icons.favorite, size: 12)
                      : const SizedBox(),
                  label: Text(pair.asLowerCase),
                ),
              ),
            );
          }),
    );
  }
}
