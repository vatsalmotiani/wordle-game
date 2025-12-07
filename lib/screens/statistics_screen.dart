import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../services/haptic_service.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final haptics = HapticService();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            haptics.lightTap();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'STATISTICS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          final stats = game.statistics;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Main Stats Grid
                _buildMainStats(stats),
                const SizedBox(height: 32),

                // Guess Distribution
                _buildGuessDistribution(stats),
                const SizedBox(height: 32),

                // High Score Card
                _buildHighScoreCard(stats),
                const SizedBox(height: 24),

                // Reset Button
                _buildResetButton(context, game, haptics),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainStats(GameStatistics stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: stats.gamesPlayed.toString(),
            label: 'Played',
          ),
          _StatItem(
            value: '${stats.winPercentage.round()}',
            label: 'Win %',
          ),
          _StatItem(
            value: stats.currentStreak.toString(),
            label: 'Current\nStreak',
            highlight: stats.currentStreak > 0,
          ),
          _StatItem(
            value: stats.maxStreak.toString(),
            label: 'Max\nStreak',
          ),
        ],
      ),
    );
  }

  Widget _buildGuessDistribution(GameStatistics stats) {
    final maxGuesses = stats.guessDistribution.reduce((a, b) => a > b ? a : b);
    final maxValue = maxGuesses > 0 ? maxGuesses : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GUESS DISTRIBUTION',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(6, (index) {
          final count = stats.guessDistribution[index];
          final percentage = count / maxValue;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final barWidth = constraints.maxWidth * percentage;
                      return Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            width: barWidth.clamp(32.0, constraints.maxWidth),
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: count > 0
                                  ? AppTheme.successGradient
                                  : null,
                              color: count > 0 ? null : AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHighScoreCard(GameStatistics stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.tileCorrect.withValues(alpha: 0.2),
            AppTheme.tileCorrect.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: AppTheme.tileCorrect.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: AppTheme.tileWrongPosition,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'HIGH SCORE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stats.highScore.toString(),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(
      BuildContext context, GameProvider game, HapticService haptics) {
    return GestureDetector(
      onTap: () {
        haptics.mediumTap();
        _showResetDialog(context, game, haptics);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(color: AppTheme.surfaceLight),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh_rounded,
              color: AppTheme.textSecondary,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Reset Statistics',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(
      BuildContext context, GameProvider game, HapticService haptics) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        title: const Text(
          'Reset Statistics?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This will permanently erase all your game data including streaks and high scores.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              haptics.lightTap();
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              haptics.heavyTap();
              game.resetStatistics();
              Navigator.pop(context);
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;

  const _StatItem({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: highlight ? AppTheme.tileCorrect : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
