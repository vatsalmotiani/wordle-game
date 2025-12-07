import 'package:flutter/services.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  /// Light tap feedback - for key presses
  Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium tap feedback - for letter entry
  Future<void> mediumTap() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy tap feedback - for submit or errors
  Future<void> heavyTap() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection changed feedback
  Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Success vibration pattern - for correct guess
  Future<void> success() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error vibration - for invalid word
  Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
  }

  /// Win celebration pattern
  Future<void> celebration() async {
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  /// Tile flip feedback
  Future<void> tileFlip() async {
    await HapticFeedback.lightImpact();
  }

  /// Backspace feedback
  Future<void> backspace() async {
    await HapticFeedback.selectionClick();
  }
}
