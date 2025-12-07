import 'letter_state.dart';

class Tile {
  final String letter;
  final LetterState state;

  const Tile({
    this.letter = '',
    this.state = LetterState.empty,
  });

  Tile copyWith({
    String? letter,
    LetterState? state,
  }) {
    return Tile(
      letter: letter ?? this.letter,
      state: state ?? this.state,
    );
  }

  bool get isEmpty => letter.isEmpty;
  bool get isFilled => letter.isNotEmpty;
}
