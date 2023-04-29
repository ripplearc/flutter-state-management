import 'package:equatable/equatable.dart';

import '../model/Word.dart';

/// This abstract class defines the state of a Bloc which generates random words
/// and stores them in [history]. It provides a list of [favorites] words based on the
/// [current] and historical state of generated words.
abstract class RandomWordState extends Equatable {
  /// Creates a new [RandomWordState] with the given `history` and `current`.
  ///
  /// The [history] parameter represents the list of generated words stored in history.
  ///
  /// The [current] parameter represents the current word being displayed.
  const RandomWordState(this.history, this.current);

  /// The list of generated words stored in history.
  final List<Word> history;

  /// The current word being displayed.
  final Word current;

  /// Returns a list of favorite words based on the current and historical state of generated words.
  ///
  /// If the current word is a favorite, it is included in the returned list. Otherwise,
  /// only the historical favorite words are returned.
  List<Word> get favorites {
    if (current.isFavorite) {
      return [...history.where((word) => word.isFavorite), current];
    } else {
      return history.where((word) => word.isFavorite).toList();
    }
  }

  @override
  List<Object?> get props => [history, current, favorites];
}

/// This class represents the state of the Bloc when the [history] is updated
/// with a new word, or the [Word.isFavorite] state changes.
class HistoryUpdated extends RandomWordState {
  const HistoryUpdated(List<Word> history, Word current)
      : super(history, current);

  @override
  String toString() {
    return '[Current]: $current \n  [History]: $history';
  }
}
