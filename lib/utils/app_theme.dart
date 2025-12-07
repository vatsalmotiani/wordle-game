import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Premium color palette - sophisticated and mature
  static const Color background = Color(0xFF121213);
  static const Color surfaceDark = Color(0xFF1A1A1B);
  static const Color surfaceLight = Color(0xFF2D2D2E);

  // Tile colors
  static const Color tileEmpty = Color(0xFF3A3A3C);
  static const Color tileFilled = Color(0xFF565758);
  static const Color tileCorrect = Color(0xFF538D4E);
  static const Color tileWrongPosition = Color(0xFFB59F3B);
  static const Color tileWrong = Color(0xFF3A3A3C);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF818384);
  static const Color textMuted = Color(0xFF565758);

  // Keyboard colors
  static const Color keyDefault = Color(0xFF818384);
  static const Color keyPressed = Color(0xFF6A6A6C);

  // Accent colors
  static const Color accent = Color(0xFF538D4E);
  static const Color accentSecondary = Color(0xFFB59F3B);

  // Gradients for premium feel
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF538D4E), Color(0xFF4A7D45)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFB59F3B), Color(0xFFA08D35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Border radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;

  // Shadows for depth
  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentSecondary,
        surface: surfaceDark,
        onSurface: textPrimary,
      ),
      fontFamily: 'SF Pro Display',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}
