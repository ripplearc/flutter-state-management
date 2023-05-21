import 'package:equatable/equatable.dart';

class Word extends Equatable {
  final String text;
  final bool isFavorite;

  const Word({
    required this.text,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [text, isFavorite];

  Word copyWith({String? text, bool? isFavorite}) {
    return Word(
      text: text ?? this.text,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
