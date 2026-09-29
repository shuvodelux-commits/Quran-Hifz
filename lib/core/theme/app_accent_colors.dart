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
    main: Color(0xFF59686D),
    strong: Color(0xFF3E4A4F),
    softTint: Color(0xFFF0F3F4),
    selectedSurface: Color(0xFFE9EDEF),
    ayahHighlight: Color(0xFF59686D),
    wordHighlight: Color(0xFF3E4A4F),
  ),
  AppAccentPreference.rose => const AppAccentColors(
    main: Color(0xFFB84A66),
    strong: Color(0xFF8D3C51),
    softTint: Color(0xFFFAEEF1),
    selectedSurface: Color(0xFFFAE9EE),
    ayahHighlight: Color(0xFFB84A66),
    wordHighlight: Color(0xFF8D3C51),
  ),
  AppAccentPreference.mint => const AppAccentColors(
    main: Color(0xFF267C63),
    strong: Color(0xFF1C6551),
    softTint: Color(0xFFE9F8F3),
    selectedSurface: Color(0xFFE5F6F0),
    ayahHighlight: Color(0xFF267C63),
    wordHighlight: Color(0xFF1C6551),
  ),
  AppAccentPreference.lavender => const AppAccentColors(
    main: Color(0xFF7058B5),
    strong: Color(0xFF53428F),
    softTint: Color(0xFFF3F1FB),
    selectedSurface: Color(0xFFF0EDFA),
    ayahHighlight: Color(0xFF7058B5),
    wordHighlight: Color(0xFF53428F),
  ),
  AppAccentPreference.sky => const AppAccentColors(
    main: Color(0xFF2E78B0),
    strong: Color(0xFF245D88),
    softTint: Color(0xFFEAF4FB),
    selectedSurface: Color(0xFFE8F3FA),
    ayahHighlight: Color(0xFF2E78B0),
    wordHighlight: Color(0xFF245D88),
  ),
};
