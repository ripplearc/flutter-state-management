import '../model/random_word/RandomWord.dart';

abstract class RandomWordEvent {}

/// Create a new random word.
class GetNewWord extends RandomWordEvent {}

/// Toggle the favorite of the given word.
class ToggleFavorite extends RandomWordEvent {
  ToggleFavorite(this.word);

  final Word word;
}

/// Undo the favorite of the given word.
class RemoveFavorite extends RandomWordEvent {
  RemoveFavorite(this.word);

  final Word word;
}
