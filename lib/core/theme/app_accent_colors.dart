import 'package:flutter/material.dart';

import '../../features/settings/domain/app_preferences.dart';

@immutable
class AppAccentColors {
  const AppAccentColors({
    required this.main,
    required this.strong,
    required this.softTint,
    required this.selectedSurface,
    required this.ayahHighlight,
    required this.wordHighlight,
  });

  final Color main;
  final Color strong;
  final Color softTint;
  final Color selectedSurface;
  final Color ayahHighlight;
  final Color wordHighlight;
}

AppAccentColors appAccentColors(AppAccentPreference accent) => switch (accent) {
  AppAccentPreference.graphite => const AppAccentColors(
    main: Color(0xFF68777B),
    strong: Color(0xFF465257),
    softTint: Color(0xFFF0F3F4),
    selectedSurface: Color(0xFFE9EDEF),
    ayahHighlight: Color(0xFF68777B),
    wordHighlight: Color(0xFF465257),
  ),
  AppAccentPreference.rose => const AppAccentColors(
    main: Color(0xFFD8798E),
    strong: Color(0xFF9D5063),
    softTint: Color(0xFFFAEEF1),
    selectedSurface: Color(0xFFFAE9EE),
    ayahHighlight: Color(0xFFD8798E),
    wordHighlight: Color(0xFF9D5063),
  ),
  AppAccentPreference.mint => const AppAccentColors(
    main: Color(0xFF54B89B),
    strong: Color(0xFF2E806B),
    softTint: Color(0xFFE9F8F3),
    selectedSurface: Color(0xFFE5F6F0),
    ayahHighlight: Color(0xFF54B89B),
    wordHighlight: Color(0xFF2E806B),
  ),
  AppAccentPreference.lavender => const AppAccentColors(
    main: Color(0xFF9586D5),
    strong: Color(0xFF685AA2),
    softTint: Color(0xFFF3F1FB),
    selectedSurface: Color(0xFFF0EDFA),
    ayahHighlight: Color(0xFF9586D5),
    wordHighlight: Color(0xFF685AA2),
  ),
  AppAccentPreference.sky => const AppAccentColors(
    main: Color(0xFF5AA3D6),
    strong: Color(0xFF2E6F9D),
    softTint: Color(0xFFEAF4FB),
    selectedSurface: Color(0xFFE8F3FA),
    ayahHighlight: Color(0xFF5AA3D6),
    wordHighlight: Color(0xFF2E6F9D),
  ),
};
