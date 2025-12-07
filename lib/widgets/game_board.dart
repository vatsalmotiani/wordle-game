import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'game_tile.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        // Guard against empty board during initialization
        if (game.board.isEmpty) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate optimal tile size based on screen
            final availableWidth = constraints.maxWidth - 40; // padding
            final availableHeight = constraints.maxHeight - 20;

            final tileWidth = (availableWidth - (4 * 6)) / 5; // 5 columns, 6px gap
            final tileHeight = (availableHeight - (5 * 6)) / 6; // 6 rows, 6px gap
            final tileSize = tileWidth < tileHeight ? tileWidth : tileHeight;
            final clampedSize = tileSize.clamp(50.0, 65.0);

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(GameProvider.maxAttempts, (row) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(GameProvider.wordLength, (col) {
                        final tile = game.board[row][col];
                        final isCurrentRow = row == game.currentRow;
                        final isRevealing = game.isRevealing &&
                                            game.revealingRow == row;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: SizedBox(
                            width: clampedSize,
                            height: clampedSize,
                            child: GameTile(
                              tile: tile,
                              isCurrentRow: isCurrentRow,
                              index: col,
                              isRevealing: isRevealing,
                              revealDelay: col * 300,
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }
}
