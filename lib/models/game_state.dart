enum GameStatus {
  playing,
  won,
  lost,
}

class GameStatistics {
  final int gamesPlayed;
  final int gamesWon;
  final int currentStreak;
  final int maxStreak;
  final List<int> guessDistribution;
  final int highScore;

  const GameStatistics({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.guessDistribution = const [0, 0, 0, 0, 0, 0],
    this.highScore = 0,
  });

  double get winPercentage =>
      gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0;

  GameStatistics copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? currentStreak,
    int? maxStreak,
    List<int>? guessDistribution,
    int? highScore,
  }) {
    return GameStatistics(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      guessDistribution: guessDistribution ?? this.guessDistribution,
      highScore: highScore ?? this.highScore,
    );
  }

  Map<String, dynamic> toJson() => {
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'currentStreak': currentStreak,
        'maxStreak': maxStreak,
        'guessDistribution': guessDistribution,
        'highScore': highScore,
      };

  factory GameStatistics.fromJson(Map<String, dynamic> json) {
    return GameStatistics(
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      maxStreak: json['maxStreak'] ?? 0,
      guessDistribution:
          List<int>.from(json['guessDistribution'] ?? [0, 0, 0, 0, 0, 0]),
      highScore: json['highScore'] ?? 0,
    );
  }
}
