import 'package:equatable/equatable.dart';

import '../model/Word.dart';

abstract class RandomWordEvent extends Equatable {}

/// Create a new random word.
class GetNewWord extends RandomWordEvent {
  @override
  List<Object?> get props => [];
}

/// Toggle the favorite of the given word.
class ToggleFavorite extends RandomWordEvent {
  ToggleFavorite(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

/// Undo the favorite of the given word.
class RemoveFavorite extends RandomWordEvent {
  RemoveFavorite(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}
