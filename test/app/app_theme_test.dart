import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/core/theme/app_accent_colors.dart';
import 'package:quran_hifz/core/theme/app_palette.dart';
import 'package:quran_hifz/core/theme/reference_colors.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  test('light defaults to Sky and all accent choices stay distinct', () {
    const defaults = AppPreferences.defaults();
    expect(defaults.theme, AppThemePreference.light);
    expect(defaults.accent, AppAccentPreference.sky);

    final themes = {
      for (final accent in AppAccentPreference.values)
        accent: appTheme(AppThemePreference.light, accent: accent),
    };

    expect(
      themes.values.map((theme) => theme.colorScheme.primary).toSet().length,
      AppAccentPreference.values.length,
    );

    for (final entry in themes.entries) {
      final tokens = appAccentColors(entry.key);
      final theme = entry.value;
      final palette = theme.extension<AppPalette>()!;
      expect(theme.colorScheme.primary, tokens.main);
      expect(theme.colorScheme.secondary, tokens.strong);
      expect(theme.colorScheme.primaryContainer, tokens.softTint);
      expect(palette.readerAccent, tokens.ayahHighlight);
      expect(palette.accentPressed, tokens.wordHighlight);
      expect(palette.accentTint, tokens.selectedSurface);
      expect(palette.quranHeader, tokens.strong);
      expect(palette.goldAccent, ReferenceColors.goldAccent);
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF8FAFA));
      expect(theme.colorScheme.surfaceContainerLow, Colors.white);
      expect(theme.colorScheme.error, const Color(0xFFB94A52));
    }
  });

  test('dark appearance uses Graphite cleanly by default', () {
    final dark = appTheme(AppThemePreference.dark);
    final graphite = appAccentColors(AppAccentPreference.graphite);
    final palette = dark.extension<AppPalette>()!;

    expect(dark.brightness, Brightness.dark);
    expect(palette.readerAccent, graphite.ayahHighlight);
    expect(palette.accentPressed, graphite.wordHighlight);
    expect(dark.scaffoldBackgroundColor, dark.colorScheme.surface);
  });

  test('Bangla and English typography remain stable across accents', () {
    final bangla = appTheme(
      AppThemePreference.light,
      accent: AppAccentPreference.sky,
    );
    expect(bangla.textTheme.bodyMedium?.fontFamily, 'SolaimanLipi');
    expect(bangla.textTheme.bodyLarge?.fontSize, 16);
    expect(bangla.textTheme.bodyMedium?.fontSize, 14);
    expect(bangla.textTheme.bodySmall?.fontSize, 13);
    expect(bangla.textTheme.titleLarge?.fontSize, 20);
    expect(bangla.textTheme.titleMedium?.fontSize, 17);
    expect(bangla.textTheme.titleLarge?.fontWeight, FontWeight.w400);

    final english = appTheme(
      AppThemePreference.light,
      accent: AppAccentPreference.rose,
      language: AppLanguage.english,
    );
    expect(english.textTheme.bodyMedium?.fontFamily, isNull);
    expect(english.textTheme.titleMedium?.fontSize, 16);
    expect(english.textTheme.titleMedium?.fontWeight, FontWeight.w500);
    expect(english.textTheme.bodyMedium?.fontSize, 14);
    expect(english.textTheme.bodyMedium?.fontWeight, FontWeight.w400);

    for (final style in [
      english.textTheme.titleLarge,
      english.textTheme.titleMedium,
      english.textTheme.bodyLarge,
      english.textTheme.bodyMedium,
      english.textTheme.bodySmall,
    ]) {
      expect(style?.color, english.colorScheme.onSurface);
    }
    expect(english.navigationBarTheme.height, inInclusiveRange(62, 66));
  });
}
