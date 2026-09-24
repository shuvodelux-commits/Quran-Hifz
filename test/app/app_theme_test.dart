import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  test('light blue is the saved default and each theme has its own seed', () {
    expect(const AppPreferences.defaults().theme, AppThemePreference.light);
    final blue = appTheme(AppThemePreference.light);
    final green = appTheme(AppThemePreference.green);
    final pink = appTheme(AppThemePreference.women);
    final dark = appTheme(AppThemePreference.dark);
    expect(blue.colorScheme.primary, isNot(green.colorScheme.primary));
    expect(pink.colorScheme.primary, isNot(blue.colorScheme.primary));
    expect(dark.brightness, Brightness.dark);
    expect(blue.colorScheme.primary, const Color(0xFF1699A3));
    expect(blue.scaffoldBackgroundColor, const Color(0xFFFAFCFC));
    expect(blue.colorScheme.surfaceContainerLow, Colors.white);
    expect(blue.colorScheme.onSurface, const Color(0xFF273238));
    expect(blue.colorScheme.onSurfaceVariant, const Color(0xFF77868D));
    expect(blue.textTheme.bodyMedium?.fontFamily, 'SolaimanLipi');
    final english = appTheme(
      AppThemePreference.light,
      language: AppLanguage.english,
    );
    expect(english.textTheme.bodyMedium?.fontFamily, isNull);
    expect(english.textTheme.titleMedium?.fontSize, 16);
    expect(english.textTheme.titleMedium?.fontWeight, FontWeight.w500);
    expect(english.textTheme.titleSmall?.fontSize, 14);
    expect(english.textTheme.titleSmall?.fontWeight, FontWeight.w500);
    expect(english.textTheme.bodyMedium?.fontSize, 14);
    expect(english.textTheme.bodyMedium?.fontWeight, FontWeight.w400);
    expect(english.textTheme.bodySmall?.fontSize, 12);
    expect(english.textTheme.bodySmall?.fontWeight, FontWeight.w400);
    expect(english.textTheme.labelMedium?.fontSize, 12);
    expect(english.textTheme.labelMedium?.fontWeight, FontWeight.w500);
    for (final style in [
      english.textTheme.titleLarge,
      english.textTheme.titleMedium,
      english.textTheme.titleSmall,
      english.textTheme.bodyLarge,
      english.textTheme.bodyMedium,
      english.textTheme.bodySmall,
      english.textTheme.labelLarge,
      english.textTheme.labelMedium,
      english.textTheme.labelSmall,
    ]) {
      expect(style?.color, english.colorScheme.onSurface);
    }
    expect(
      english.primaryTextTheme.titleLarge?.color,
      english.colorScheme.onPrimary,
    );

    final englishDark = appTheme(
      AppThemePreference.dark,
      language: AppLanguage.english,
    );
    expect(
      englishDark.textTheme.titleLarge?.color,
      englishDark.colorScheme.onSurface,
    );
    expect(
      englishDark.textTheme.bodyMedium?.color,
      englishDark.colorScheme.onSurface,
    );
    expect(
      englishDark.primaryTextTheme.titleLarge?.color,
      englishDark.colorScheme.onPrimary,
    );
    expect(blue.textTheme.bodyMedium?.fontSize, 13);
    expect(blue.textTheme.titleLarge?.fontSize, 20);
    expect(blue.textTheme.titleLarge?.fontWeight, FontWeight.w600);
    expect(blue.colorScheme.secondary, const Color(0xFF117E87));
    expect(blue.colorScheme.primaryContainer, const Color(0xFFEAF7F8));
    expect(blue.colorScheme.onPrimaryContainer, const Color(0xFF273238));
    expect(blue.colorScheme.outline, const Color(0xFF77868D));
    expect(blue.colorScheme.outlineVariant, const Color(0xFFDDE8EA));
    expect(blue.cardTheme.elevation, 0);
    expect(blue.cardTheme.shape, isA<RoundedRectangleBorder>());
    expect(blue.navigationBarTheme.height, inInclusiveRange(60, 64));
    expect(blue.scaffoldBackgroundColor, blue.colorScheme.surface);
    expect(green.scaffoldBackgroundColor, green.colorScheme.surface);
    expect(pink.scaffoldBackgroundColor, pink.colorScheme.surface);
    expect(dark.scaffoldBackgroundColor, dark.colorScheme.surface);
  });
}
