import 'package:english_words/english_words.dart';
import 'package:equatable/equatable.dart';

class Word extends Equatable {
  final WordPair text;
  final bool isFavorite;

  const Word({
    required this.text,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [text, isFavorite];

  Word copyWith({WordPair? text, bool? isFavorite}) {
    return Word(
      text: text ?? this.text,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  static Word createInstance() =>
      Word(text: WordPair.random(), isFavorite: false);
}
