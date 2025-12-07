import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class StorageService {
  static const String _statsKey = 'wordle_statistics';
  static const String _lastPlayedKey = 'last_played_date';

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<GameStatistics> getStatistics() async {
    _prefs ??= await SharedPreferences.getInstance();

    final String? statsJson = _prefs!.getString(_statsKey);
    if (statsJson == null) {
      return const GameStatistics();
    }

    try {
      final Map<String, dynamic> json = jsonDecode(statsJson);
      return GameStatistics.fromJson(json);
    } catch (e) {
      return const GameStatistics();
    }
  }

  Future<void> saveStatistics(GameStatistics stats) async {
    _prefs ??= await SharedPreferences.getInstance();

    final String statsJson = jsonEncode(stats.toJson());
    await _prefs!.setString(_statsKey, statsJson);
  }

  Future<GameStatistics> recordWin(int guessCount) async {
    final stats = await getStatistics();

    final newStreak = stats.currentStreak + 1;
    final newMaxStreak = newStreak > stats.maxStreak ? newStreak : stats.maxStreak;

    // Calculate score: fewer guesses = higher score, streaks multiply
    final baseScore = (7 - guessCount) * 100;
    final streakBonus = newStreak * 50;
    final roundScore = baseScore + streakBonus;
    final newHighScore = roundScore > stats.highScore ? roundScore : stats.highScore;

    final newDistribution = List<int>.from(stats.guessDistribution);
    if (guessCount >= 1 && guessCount <= 6) {
      newDistribution[guessCount - 1]++;
    }

    final newStats = stats.copyWith(
      gamesPlayed: stats.gamesPlayed + 1,
      gamesWon: stats.gamesWon + 1,
      currentStreak: newStreak,
      maxStreak: newMaxStreak,
      guessDistribution: newDistribution,
      highScore: newHighScore,
    );

    await saveStatistics(newStats);
    await _updateLastPlayed();

    return newStats;
  }

  Future<GameStatistics> recordLoss() async {
    final stats = await getStatistics();

    final newStats = stats.copyWith(
      gamesPlayed: stats.gamesPlayed + 1,
      currentStreak: 0,
    );

    await saveStatistics(newStats);
    await _updateLastPlayed();

    return newStats;
  }

  Future<void> _updateLastPlayed() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_lastPlayedKey, DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastPlayed() async {
    _prefs ??= await SharedPreferences.getInstance();

    final String? dateStr = _prefs!.getString(_lastPlayedKey);
    if (dateStr == null) return null;

    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  Future<void> resetStatistics() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_statsKey);
    await _prefs!.remove(_lastPlayedKey);
  }
}
