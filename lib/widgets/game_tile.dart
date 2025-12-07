import 'package:flutter/material.dart';
import '../models/letter_state.dart';
import '../models/tile.dart';
import '../utils/app_theme.dart';

class GameTile extends StatefulWidget {
  final Tile tile;
  final bool isCurrentRow;
  final int index;
  final bool isRevealing;
  final int revealDelay;

  const GameTile({
    super.key,
    required this.tile,
    this.isCurrentRow = false,
    this.index = 0,
    this.isRevealing = false,
    this.revealDelay = 0,
  });

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile>
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(GameTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Pop animation when letter is added
    if (widget.tile.isFilled && !oldWidget.tile.isFilled) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.tile.state) {
      case LetterState.correct:
        return AppTheme.tileCorrect;
      case LetterState.wrongPosition:
        return AppTheme.tileWrongPosition;
      case LetterState.wrong:
        return AppTheme.tileWrong;
      case LetterState.filled:
        return Colors.transparent;
      case LetterState.empty:
        return Colors.transparent;
    }
  }

  Color _getBorderColor() {
    if (widget.tile.state.isRevealed) {
      return Colors.transparent;
    }
    if (widget.tile.isFilled) {
      return AppTheme.textSecondary;
    }
    return AppTheme.tileEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(
          begin: 0.0,
          end: widget.tile.state.isRevealed ? 1.0 : 0.0,
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          // Flip animation
          final isFlipped = value > 0.5;
          final rotationValue = value * 3.14159; // pi

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(rotationValue),
            child: Container(
              decoration: BoxDecoration(
                color: isFlipped ? _getBackgroundColor() : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                border: Border.all(
                  color: isFlipped ? Colors.transparent : _getBorderColor(),
                  width: 2,
                ),
                boxShadow: widget.tile.state.isRevealed
                    ? [
                        BoxShadow(
                          color: _getBackgroundColor().withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateX(isFlipped ? 3.14159 : 0),
                  child: Text(
                    widget.tile.letter,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
