import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/Word.dart';
import '../repository/WordRepository.dart';
import 'event.dart';
import 'state.dart';

class RandomWordBloc extends Bloc<RandomWordEvent, RandomWordState> {
  List<Word> _history = <Word>[];
  late Word _current;
  final RandomWordFactory randomWordFactory;

  RandomWordBloc(this.randomWordFactory)
      : super(HistoryUpdated(
            List.empty(),
            Word(
                text: randomWordFactory.generateRandomWord(),
                isFavorite: false))) {
    on<GetNewWord>(_getNewWord);
    on<ToggleFavorite>(_toggleFavorite);
    on<RemoveFavorite>(_removeFavorite);
    _current = state.current;
  }

  /// Respond to events
  void _getNewWord(GetNewWord event, Emitter<RandomWordState> emit) async {
    _history.insert(0, _current);
    _current =
        Word(text: randomWordFactory.generateRandomWord(), isFavorite: false);
    emit(HistoryUpdated(_history, _current));
  }

  void _toggleFavorite(ToggleFavorite event, Emitter<RandomWordState> emit) {
    _updateFavorite(event.text, emit);
  }

  void _removeFavorite(RemoveFavorite event, Emitter<RandomWordState> emit) {
    _updateFavorite(event.text, emit, shouldRemoveFavorite: true);
  }

  /// Helper
  void _updateFavorite(
    String text,
    Emitter<RandomWordState> emit, {
    bool shouldRemoveFavorite = false,
  }) {
    if (text == _current.text) {
      _updateFavoriteOfCurrentWord(shouldRemoveFavorite);
    } else {
      _updateFavoriteOfHistoryWord(text, shouldRemoveFavorite);
    }
    emit(HistoryUpdated(_history, _current));
  }

  void _updateFavoriteOfHistoryWord(String text, bool shouldRemoveFavorite) {
    _history = _history.map((word) {
      if (word.text == text) {
        return word.copyWith(
            isFavorite: shouldRemoveFavorite ? false : !word.isFavorite);
      } else {
        return word;
      }
    }).toList();
  }

  void _updateFavoriteOfCurrentWord(bool shouldRemoveFavorite) {
    _current = _current.copyWith(
        isFavorite: shouldRemoveFavorite ? false : !_current.isFavorite);
  }
}
