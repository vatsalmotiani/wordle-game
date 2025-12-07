# Wordle

A clean, ad-free Wordle clone built with Flutter. No distractions, just the game.

## Features

- **Classic Wordle gameplay** - Guess the 5-letter word in 6 attempts
- **Visual feedback** - Green for correct, yellow for wrong position, gray for not in word
- **Animated tile reveals** - Smooth flip animations when submitting guesses
- **On-screen keyboard** - Color-coded keys that update as you play
- **Statistics tracking** - Games played, win %, current streak, max streak, and guess distribution
- **High score system** - Track your best performances
- **Haptic feedback** - Tactile responses for key presses, errors, and wins
- **Dark theme** - Easy on the eyes
- **Persistent storage** - Your stats are saved locally
- **Confetti celebration** - Win animation when you solve the puzzle

## Screenshots
<img width="603" height="1311" alt="IMG_6581" src="https://github.com/user-attachments/assets/43decd5e-6ed4-48d3-8549-c4d93981c47a" />
<img width="603" height="1311" alt="IMG_6583" src="https://github.com/user-attachments/assets/95941617-334a-47b9-8051-30e5aa8d80aa" />
<img width="603" height="1311" alt="IMG_6584" src="https://github.com/user-attachments/assets/26fb04f1-d305-4829-a215-5da9e0fc747b" />


## Getting Started

### Prerequisites

- Flutter SDK 3.10.3 or higher
- iOS Simulator or Android Emulator (or physical device)

### Installation

```bash
# Clone the repository
git clone https://github.com/vatsalmotiani/wordle-game.git
cd wordle-game

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── data/
│   └── words.dart         # Word lists (answers + valid guesses)
├── models/
│   ├── game_state.dart    # Game status and statistics models
│   ├── letter_state.dart  # Letter state enum (correct, wrong position, etc.)
│   └── tile.dart          # Tile model for the game board
├── providers/
│   └── game_provider.dart # Game logic and state management
├── screens/
│   ├── game_screen.dart   # Main game screen
│   └── statistics_screen.dart # Stats display
├── services/
│   ├── haptic_service.dart   # Haptic feedback
│   └── storage_service.dart  # Local persistence
├── utils/
│   └── app_theme.dart     # Colors and styling
└── widgets/
    ├── game_board.dart    # 6x5 tile grid
    ├── game_tile.dart     # Individual tile with animations
    ├── game_over_dialog.dart # Win/lose dialog
    ├── keyboard.dart      # On-screen keyboard
    ├── message_overlay.dart  # Toast messages
    └── stats_bar.dart     # Statistics display bar
```

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **SharedPreferences** - Local storage for statistics
- **Confetti** - Win celebration animations

## License

MIT
