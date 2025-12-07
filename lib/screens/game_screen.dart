import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/game_board.dart';
import '../widgets/keyboard.dart';
import '../widgets/message_overlay.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/stats_bar.dart';
import '../services/haptic_service.dart';
import 'statistics_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final HapticService _haptics = HapticService();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, game, child) {
            return Stack(
              children: [
                Column(
                  children: [
                    // App Bar
                    _buildAppBar(context, game),

                    // Stats Bar
                    const StatsBar(),

                    // Game Board
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) {
                            final shake = _shakeAnimation.value *
                                8 *
                                (1 - _shakeAnimation.value);
                            return Transform.translate(
                              offset: Offset(shake * ((_shakeAnimation.value * 10).round() % 2 == 0 ? 1 : -1), 0),
                              child: child,
                            );
                          },
                          child: const GameBoard(),
                        ),
                      ),
                    ),

                    // Keyboard
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: GameKeyboard(),
                    ),
                  ],
                ),

                // Message Overlay
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: MessageOverlay(
                      message: game.message,
                      isVisible: game.showMessage,
                    ),
                  ),
                ),

                // Game Over Dialog
                if (game.gameStatus != GameStatus.playing)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: GameOverDialog(
                        isWin: game.gameStatus == GameStatus.won,
                        targetWord: game.targetWord,
                        attempts: game.currentRow + (game.gameStatus == GameStatus.won ? 0 : 1),
                        statistics: game.statistics,
                        onPlayAgain: () {
                          _haptics.mediumTap();
                          game.startNewGame();
                        },
                        onViewStats: () {
                          _haptics.lightTap();
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const StatisticsScreen(),
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, GameProvider game) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info Button
          _AppBarButton(
            icon: Icons.help_outline_rounded,
            onTap: () {
              _haptics.lightTap();
              _showHelpDialog(context);
            },
          ),

          // Title
          const Text(
            'WORDLE',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: 4,
            ),
          ),

          // Stats Button
          _AppBarButton(
            icon: Icons.bar_chart_rounded,
            onTap: () {
              _haptics.lightTap();
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const StatisticsScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        title: const Text(
          'How To Play',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guess the word in 6 tries.',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildHelpRow(
              color: AppTheme.tileCorrect,
              text: 'Green: Correct letter, correct spot',
            ),
            const SizedBox(height: 8),
            _buildHelpRow(
              color: AppTheme.tileWrongPosition,
              text: 'Yellow: Correct letter, wrong spot',
            ),
            const SizedBox(height: 8),
            _buildHelpRow(
              color: AppTheme.tileWrong,
              text: 'Gray: Letter not in word',
            ),
            const SizedBox(height: 16),
            const Text(
              'Build a streak by guessing correctly on consecutive games!',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it!',
              style: TextStyle(color: AppTheme.tileCorrect),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpRow({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _AppBarButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_AppBarButton> createState() => _AppBarButtonState();
}

class _AppBarButtonState extends State<_AppBarButton>
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            widget.icon,
            color: AppTheme.textSecondary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
