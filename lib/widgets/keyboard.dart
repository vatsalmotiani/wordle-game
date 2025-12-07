import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/letter_state.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../services/haptic_service.dart';

class GameKeyboard extends StatelessWidget {
  const GameKeyboard({super.key});

  // iOS-style keyboard layout (no ENTER in row)
  static const List<List<String>> _keyRows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  @override
  Widget build(BuildContext context) {
    final haptics = HapticService();

    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First row - QWERTY
              _buildKeyRow(_keyRows[0], game, haptics),
              const SizedBox(height: 8),

              // Second row - ASDF with slight indent
              _buildKeyRow(_keyRows[1], game, haptics, indent: true),
              const SizedBox(height: 8),

              // Third row - with backspace
              _buildBottomRow(_keyRows[2], game, haptics),
              const SizedBox(height: 12),

              // Large submit button centered below keyboard
              _SubmitButton(
                onTap: () {
                  haptics.mediumTap();
                  game.submitGuess();
                },
                isEnabled: game.isCurrentRowComplete,
                isValid: game.isCurrentGuessValid,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKeyRow(
    List<String> keys,
    GameProvider game,
    HapticService haptics, {
    bool indent = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (indent) const SizedBox(width: 16),
        ...keys.map((key) => _LetterKey(
              letter: key,
              state: game.keyboardState[key],
              onTap: () {
                haptics.lightTap();
                game.addLetter(key);
              },
            )),
        if (indent) const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildBottomRow(
    List<String> keys,
    GameProvider game,
    HapticService haptics,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Spacer to balance backspace
        const SizedBox(width: 44),
        const SizedBox(width: 5),
        // Letter keys
        ...keys.map((key) => _LetterKey(
              letter: key,
              state: game.keyboardState[key],
              onTap: () {
                haptics.lightTap();
                game.addLetter(key);
              },
            )),
        const SizedBox(width: 5),
        // Backspace key
        _BackspaceKey(
          onTap: () {
            haptics.lightTap();
            game.removeLetter();
          },
        ),
      ],
    );
  }
}

// iOS-style letter key
class _LetterKey extends StatefulWidget {
  final String letter;
  final LetterState? state;
  final VoidCallback onTap;

  const _LetterKey({
    required this.letter,
    this.state,
    required this.onTap,
  });

  @override
  State<_LetterKey> createState() => _LetterKeyState();
}

class _LetterKeyState extends State<_LetterKey>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.state) {
      case LetterState.correct:
        return AppTheme.tileCorrect;
      case LetterState.wrongPosition:
        return AppTheme.tileWrongPosition;
      case LetterState.wrong:
        return const Color(0xFF3A3A3C);
      default:
        return const Color(0xFF787880); // iOS keyboard key color
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 32,
            height: 46,
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.letter,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// iOS-style backspace key
class _BackspaceKey extends StatefulWidget {
  final VoidCallback onTap;

  const _BackspaceKey({required this.onTap});

  @override
  State<_BackspaceKey> createState() => _BackspaceKeyState();
}

class _BackspaceKeyState extends State<_BackspaceKey>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
          width: 44,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF565658),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

// Large prominent submit button
class _SubmitButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isEnabled;
  final bool isValid;

  const _SubmitButton({
    required this.onTap,
    required this.isEnabled,
    required this.isValid,
  });

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
    // Determine button color based on state
    Color buttonColor;
    Color textColor;

    if (!widget.isEnabled) {
      // Not enough letters - disabled gray
      buttonColor = const Color(0xFF3A3A3C);
      textColor = const Color(0xFF6A6A6C);
    } else if (widget.isValid) {
      // Valid word - green
      buttonColor = AppTheme.tileCorrect;
      textColor = Colors.white;
    } else {
      // Invalid word - muted
      buttonColor = const Color(0xFF565658);
      textColor = const Color(0xFFAAAAAA);
    }

    return GestureDetector(
      onTapDown: widget.isEnabled ? (_) => _controller.forward() : null,
      onTapUp: widget.isEnabled
          ? (_) {
              _controller.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 200,
          height: 50,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isEnabled && widget.isValid
                ? [
                    BoxShadow(
                      color: AppTheme.tileCorrect.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isEnabled && widget.isValid)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.check_rounded,
                      color: textColor,
                      size: 22,
                    ),
                  ),
                Text(
                  'SUBMIT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
