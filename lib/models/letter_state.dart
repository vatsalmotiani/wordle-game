enum LetterState {
  empty,
  filled,
  correct,
  wrongPosition,
  wrong,
}

extension LetterStateExtension on LetterState {
  bool get isRevealed =>
      this == LetterState.correct ||
      this == LetterState.wrongPosition ||
      this == LetterState.wrong;
}
