import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namer_app/model/Word.dart';
import 'package:namer_app/random_word/bloc.dart';
import 'package:namer_app/random_word/event.dart';
import 'package:namer_app/random_word/state.dart';

/// A widget that displays a list of previously generated words.
///
/// This widget is used to display a list of previously generated [RandomWordState.history] that
/// the user has seen. It is an animated list that is displayed on the top
/// of the screen and is updated every time a new word is generated. The user
/// can tap on a word in the list to toggle its favorite state, which triggers [RandomWordEvent.ToggleFavorite].
///
/// The [history] is a list of previously generated [Word] objects.
/// The [listKey] is a [GlobalKey] object used to control the state
/// of the animated list, e.g., inserting a new word to the bottom.
///
class HistoryListView extends StatefulWidget {
  const HistoryListView({
    super.key,
    required this.history,
    required this.listKey,
  });

  final List<Word> history;
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
            final word = widget.history[index];
            return SizeTransition(
              sizeFactor: animation,
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    context
                        .read<RandomWordBloc>()
                        .add(ToggleFavorite(word.text));
                  },
                  icon: word.isFavorite
                      ? const Icon(Icons.favorite, size: 12)
                      : const SizedBox(),
                  label: Text(word.text),
                ),
              ),
            );
          }),
    );
  }
}
