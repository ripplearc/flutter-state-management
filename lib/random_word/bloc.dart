import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/random_word/RandomWord.dart';
import 'event.dart';
import 'state.dart';

class RandomWordBloc extends Bloc<RandomWordEvent, RandomWordState> {
  final List<Word> _history = <Word>[];
  late Word _current;

  RandomWordBloc()
      : super(HistoryUpdated(List.empty(), Word.createInstance())) {
    on<GetNewWord>(_getNewWord);
    on<ToggleFavorite>(_toggleFavorite);
    on<RemoveFavorite>(_removeFavorite);
    _current = state.current;
  }

  /// Respond to events
  void _getNewWord(GetNewWord event, Emitter<RandomWordState> emit) async {
    _history.insert(0, _current);
    _current = Word.createInstance();
    emit(HistoryUpdated(_history, _current));
  }

  void _toggleFavorite(ToggleFavorite event, Emitter<RandomWordState> emit) {
    _updateFavorite(event.word, emit);
  }

  void _removeFavorite(RemoveFavorite event, Emitter<RandomWordState> emit) {
    _updateFavorite(event.word, emit, shouldRemoveFavorite: true);
  }

  /// Helper
  void _updateFavorite(
    Word word,
    Emitter<RandomWordState> emit, {
    bool shouldRemoveFavorite = false,
  }) {
    if (word.text == _current.text) {
      _updateFavoriteOfCurrentWord(shouldRemoveFavorite);
    } else {
      _updateFavoriteOfHistoryWord(word, shouldRemoveFavorite);
    }
    emit(HistoryUpdated(_history, _current));
  }

  void _updateFavoriteOfHistoryWord(Word word, bool shouldRemoveFavorite) {
    final index = _history.indexWhere((item) => item.text == word.text);
    _history[index] = _history[index].copyWith(
        isFavorite: shouldRemoveFavorite ? false : !_history[index].isFavorite);
  }

  void _updateFavoriteOfCurrentWord(bool shouldRemoveFavorite) {
    _current = _current.copyWith(
        isFavorite: shouldRemoveFavorite ? false : !_current.isFavorite);
  }
}
