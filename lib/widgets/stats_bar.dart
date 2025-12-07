import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final stats = game.statistics;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(
                icon: Icons.local_fire_department_rounded,
                value: stats.currentStreak.toString(),
                label: 'Streak',
                color: stats.currentStreak > 0
                    ? AppTheme.tileWrongPosition
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 20),
              _StatChip(
                icon: Icons.emoji_events_rounded,
                value: stats.highScore.toString(),
                label: 'Best',
                color: AppTheme.tileCorrect,
              ),
              const SizedBox(width: 20),
              _StatChip(
                icon: Icons.check_circle_rounded,
                value: '${stats.winPercentage.round()}%',
                label: 'Win Rate',
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textMuted,
                height: 1.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
