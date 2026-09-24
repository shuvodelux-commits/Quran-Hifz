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
    expect(
      appTheme(
        AppThemePreference.light,
        language: AppLanguage.english,
      ).textTheme.bodyMedium?.fontFamily,
      'Inter',
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
