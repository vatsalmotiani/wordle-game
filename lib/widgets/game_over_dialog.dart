import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/game_state.dart';
import '../utils/app_theme.dart';

class GameOverDialog extends StatefulWidget {
  final bool isWin;
  final String targetWord;
  final int attempts;
  final GameStatistics statistics;
  final VoidCallback onPlayAgain;
  final VoidCallback onViewStats;

  const GameOverDialog({
    super.key,
    required this.isWin,
    required this.targetWord,
    required this.attempts,
    required this.statistics,
    required this.onPlayAgain,
    required this.onViewStats,
  });

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _slideController.forward();
    _bounceController.forward();

    if (widget.isWin) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
              border: Border.all(
                color: AppTheme.surfaceLight,
                width: 1,
              ),
              boxShadow: AppTheme.elevatedShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _bounceAnimation,
                  child: _buildHeader(),
                ),
                const SizedBox(height: 24),
                _buildWordReveal(),
                const SizedBox(height: 24),
                _buildStats(),
                const SizedBox(height: 28),
                _buildButtons(),
              ],
            ),
          ),
        ),
        if (widget.isWin)
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppTheme.tileCorrect,
              AppTheme.tileWrongPosition,
              Colors.white,
              Color(0xFF6366F1),
              Color(0xFFEC4899),
            ],
            numberOfParticles: 30,
            maxBlastForce: 50,
            minBlastForce: 20,
            gravity: 0.2,
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.isWin
                ? AppTheme.successGradient
                : LinearGradient(
                    colors: [
                      AppTheme.tileWrong,
                      AppTheme.tileWrong.withValues(alpha: 0.8),
                    ],
                  ),
            boxShadow: [
              BoxShadow(
                color: (widget.isWin ? AppTheme.tileCorrect : AppTheme.tileWrong)
                    .withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            widget.isWin ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.isWin ? 'Brilliant!' : 'Better Luck Next Time',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        if (widget.isWin)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Solved in ${widget.attempts} ${widget.attempts == 1 ? 'guess' : 'guesses'}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWordReveal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        children: [
          const Text(
            'THE WORD WAS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.targetWord,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          value: widget.statistics.currentStreak.toString(),
          label: 'Current\nStreak',
          highlight: widget.statistics.currentStreak > 0,
        ),
        Container(
          width: 1,
          height: 40,
          color: AppTheme.surfaceLight,
        ),
        _buildStatItem(
          value: widget.statistics.maxStreak.toString(),
          label: 'Max\nStreak',
        ),
        Container(
          width: 1,
          height: 40,
          color: AppTheme.surfaceLight,
        ),
        _buildStatItem(
          value: widget.statistics.highScore.toString(),
          label: 'High\nScore',
          highlight: true,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    bool highlight = false,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
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

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: _AnimatedButton(
            label: 'Stats',
            icon: Icons.bar_chart_rounded,
            isPrimary: false,
            onTap: widget.onViewStats,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _AnimatedButton(
            label: 'Play Again',
            icon: Icons.refresh_rounded,
            isPrimary: true,
            onTap: widget.onPlayAgain,
          ),
        ),
      ],
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _AnimatedButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: widget.isPrimary ? AppTheme.successGradient : null,
            color: widget.isPrimary ? null : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: AppTheme.tileCorrect.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: AppTheme.textPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
