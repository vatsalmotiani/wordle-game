import 'dart:math';
import 'package:flutter/material.dart';
import '../models/letter_state.dart';
import '../models/game_state.dart';
import '../models/tile.dart';
import '../data/words.dart';
import '../services/haptic_service.dart';
import '../services/storage_service.dart';

class GameProvider extends ChangeNotifier {
  static const int maxAttempts = 6;
  static const int wordLength = 5;

  final HapticService _haptics = HapticService();
  final StorageService _storage = StorageService();

  String _targetWord = '';
  List<List<Tile>> _board = [];
  int _currentRow = 0;
  int _currentCol = 0;
  GameStatus _gameStatus = GameStatus.playing;
  Map<String, LetterState> _keyboardState = {};
  GameStatistics _statistics = const GameStatistics();
  String _message = '';
  bool _showMessage = false;
  bool _isRevealing = false;
  int _revealingRow = -1;

  // Getters
  String get targetWord => _targetWord;
  List<List<Tile>> get board => _board;
  int get currentRow => _currentRow;
  int get currentCol => _currentCol;
  GameStatus get gameStatus => _gameStatus;
  Map<String, LetterState> get keyboardState => _keyboardState;
  GameStatistics get statistics => _statistics;
  String get message => _message;
  bool get showMessage => _showMessage;
  bool get isRevealing => _isRevealing;
  int get revealingRow => _revealingRow;

  // Returns true if current row has 5 letters and is a valid word
  bool get isCurrentGuessValid {
    if (_currentCol != wordLength) return false;
    return _isValidWord(_getCurrentGuess());
  }

  // Returns true if current row is complete (5 letters)
  bool get isCurrentRowComplete => _currentCol == wordLength;

  GameProvider() {
    _initGame();
  }

  Future<void> _initGame() async {
    await _storage.init();
    _statistics = await _storage.getStatistics();
    startNewGame();
  }

  void startNewGame() {
    _targetWord = _getRandomWord();
    _board = List.generate(
      maxAttempts,
      (_) => List.generate(wordLength, (_) => const Tile()),
    );
    _currentRow = 0;
    _currentCol = 0;
    _gameStatus = GameStatus.playing;
    _keyboardState = {};
    _message = '';
    _showMessage = false;
    _isRevealing = false;
    _revealingRow = -1;
    notifyListeners();
  }

  String _getRandomWord() {
    final random = Random();
    return wordList[random.nextInt(wordList.length)].toUpperCase();
  }

  void addLetter(String letter) {
    if (_gameStatus != GameStatus.playing || _isRevealing) return;
    if (_currentCol >= wordLength) return;

    _haptics.lightTap();

    _board[_currentRow][_currentCol] = Tile(
      letter: letter.toUpperCase(),
      state: LetterState.filled,
    );
    _currentCol++;
    notifyListeners();
  }

  void removeLetter() {
    if (_gameStatus != GameStatus.playing || _isRevealing) return;
    if (_currentCol <= 0) return;

    _haptics.backspace();

    _currentCol--;
    _board[_currentRow][_currentCol] = const Tile();
    notifyListeners();
  }

  Future<void> submitGuess() async {
    if (_gameStatus != GameStatus.playing || _isRevealing) return;
    if (_currentCol != wordLength) {
      _showTemporaryMessage('Not enough letters');
      _haptics.error();
      return;
    }

    final guess = _getCurrentGuess();

    // Check if word is valid
    if (!_isValidWord(guess)) {
      _showTemporaryMessage('Not in word list');
      _haptics.error();
      return;
    }

    _haptics.mediumTap();

    // Start reveal animation
    _isRevealing = true;
    _revealingRow = _currentRow;
    notifyListeners();

    // Evaluate the guess
    final results = _evaluateGuess(guess);

    // Animate tile reveals one by one
    for (int i = 0; i < wordLength; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      _board[_currentRow][i] = _board[_currentRow][i].copyWith(
        state: results[i],
      );
      _updateKeyboardState(_board[_currentRow][i].letter, results[i]);
      _haptics.tileFlip();
      notifyListeners();
    }

    await Future.delayed(const Duration(milliseconds: 200));
    _isRevealing = false;
    _revealingRow = -1;

    // Check win/lose conditions
    if (guess == _targetWord) {
      _gameStatus = GameStatus.won;
      _statistics = await _storage.recordWin(_currentRow + 1);
      _haptics.celebration();
      notifyListeners();
      return;
    }

    _currentRow++;
    _currentCol = 0;

    if (_currentRow >= maxAttempts) {
      _gameStatus = GameStatus.lost;
      _statistics = await _storage.recordLoss();
      _haptics.error();
      _showTemporaryMessage(_targetWord, duration: 5);
    }

    notifyListeners();
  }

  String _getCurrentGuess() {
    return _board[_currentRow]
        .map((tile) => tile.letter)
        .join();
  }

  bool _isValidWord(String word) {
    final lowerWord = word.toLowerCase();
    return wordList.contains(lowerWord) || validGuesses.contains(lowerWord);
  }

  List<LetterState> _evaluateGuess(String guess) {
    final results = List<LetterState>.filled(wordLength, LetterState.wrong);
    final targetLetters = _targetWord.split('');
    final guessLetters = guess.split('');
    final used = List<bool>.filled(wordLength, false);

    // First pass: find correct positions
    for (int i = 0; i < wordLength; i++) {
      if (guessLetters[i] == targetLetters[i]) {
        results[i] = LetterState.correct;
        used[i] = true;
      }
    }

    // Second pass: find wrong positions
    for (int i = 0; i < wordLength; i++) {
      if (results[i] == LetterState.correct) continue;

      for (int j = 0; j < wordLength; j++) {
        if (!used[j] && guessLetters[i] == targetLetters[j]) {
          results[i] = LetterState.wrongPosition;
          used[j] = true;
          break;
        }
      }
    }

    return results;
  }

  void _updateKeyboardState(String letter, LetterState state) {
    final currentState = _keyboardState[letter];

    // Priority: correct > wrongPosition > wrong
    if (currentState == LetterState.correct) {
      return;
    }
    if (currentState == LetterState.wrongPosition &&
        state != LetterState.correct) {
      return;
    }

    _keyboardState[letter] = state;
  }

  void _showTemporaryMessage(String msg, {int duration = 2}) {
    _message = msg;
    _showMessage = true;
    notifyListeners();

    Future.delayed(Duration(seconds: duration), () {
      _showMessage = false;
      notifyListeners();
    });
  }

  Future<void> refreshStatistics() async {
    _statistics = await _storage.getStatistics();
    notifyListeners();
  }

  Future<void> resetStatistics() async {
    await _storage.resetStatistics();
    _statistics = const GameStatistics();
    notifyListeners();
  }
}
