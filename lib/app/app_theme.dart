import 'package:flutter/material.dart';

import '../core/theme/app_accent_colors.dart';
import '../core/theme/app_palette.dart';
import '../core/theme/reference_colors.dart';
import '../features/settings/domain/app_preferences.dart';

ThemeData appTheme(
  AppThemePreference preference, {
  AppAccentPreference? accent,
  AppLanguage language = AppLanguage.bangla,
}) {
  final dark = preference == AppThemePreference.dark;
  final effectiveAccent =
      accent ??
      (dark ? AppAccentPreference.graphite : AppAccentPreference.sky);
  final accentColors = appAccentColors(effectiveAccent);
  var scheme = ColorScheme.fromSeed(
    seedColor: accentColors.main,
    brightness: dark ? Brightness.dark : Brightness.light,
  );
  if (!dark) {
    scheme = scheme.copyWith(
      primary: accentColors.main,
      onPrimary: Colors.white,
      primaryContainer: accentColors.softTint,
      onPrimaryContainer: const Color(0xFF253533),
      secondary: accentColors.strong,
      onSecondary: Colors.white,
      secondaryContainer: accentColors.softTint,
      onSecondaryContainer: const Color(0xFF253533),
      tertiary: accentColors.main,
      onTertiary: Colors.white,
      tertiaryContainer: accentColors.softTint,
      onTertiaryContainer: const Color(0xFF253533),
      error: const Color(0xFFB94A52),
      surface: const Color(0xFFF8FAFA),
      onSurface: const Color(0xFF253533),
      onSurfaceVariant: const Color(0xFF6B7775),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Colors.white,
      surfaceContainer: const Color(0xFFF3F6F5),
      surfaceContainerHigh: const Color(0xFFEDF1F0),
      surfaceContainerHighest: const Color(0xFFE6ECEA),
      outline: const Color(0xFF9AA6A2),
      outlineVariant: const Color(0xFFE2E8E6),
      inverseSurface: const Color(0xFF253533),
      onInverseSurface: Colors.white,
      inversePrimary: accentColors.main,
    );
  }

  final androidTypography = Typography.material2021(
    platform: TargetPlatform.android,
    colorScheme: scheme,
  );
  final fontFamily = language == AppLanguage.bangla ? 'SolaimanLipi' : null;
  final textTheme = language == AppLanguage.bangla
      ? _compactTextTheme('SolaimanLipi', scheme)
      : androidTypography.englishLike.apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
          decorationColor: scheme.onSurface,
        );
  final primaryTextTheme = textTheme.apply(
    bodyColor: scheme.onPrimary,
    displayColor: scheme.onPrimary,
    decorationColor: scheme.onPrimary,
  );
  final rounded12 = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: scheme.outlineVariant),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    extensions: [
      AppPalette(
        readerAccent: accentColors.ayahHighlight,
        accentPressed: accentColors.wordHighlight,
        accentTint: accentColors.selectedSurface,
        cardSurface: scheme.surfaceContainerLow,
        secondaryText: scheme.onSurfaceVariant,
        subtleBorder: scheme.outlineVariant,
        quranHeader: accentColors.strong,
        goldAccent: ReferenceColors.goldAccent,
      ),
    ],
    brightness: scheme.brightness,
    fontFamily: fontFamily,
    textTheme: textTheme,
    primaryTextTheme: primaryTextTheme,
    scaffoldBackgroundColor: scheme.surface,
    visualDensity: VisualDensity.standard,
    iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 20),
    primaryIconTheme: IconThemeData(color: scheme.onPrimary, size: 20),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: rounded12,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: textTheme.titleMedium,
      contentTextStyle: textTheme.bodyMedium,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      modalBackgroundColor: scheme.surfaceContainerLow,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: IconThemeData(color: scheme.onSurface, size: 20),
      actionsIconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 20),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      elevation: 0,
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 20,
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => textTheme.labelSmall?.copyWith(
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      dense: false,
      minTileHeight: 56,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      iconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      titleTextStyle: textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
      ),
      subtitleTextStyle: textTheme.bodySmall,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainer,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      labelStyle: textTheme.bodySmall,
      helperStyle: textTheme.bodySmall,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      selectedColor: scheme.primaryContainer,
      side: BorderSide(color: scheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: textTheme.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: 6),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        textStyle: textTheme.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size.square(44),
        iconSize: 20,
        foregroundColor: scheme.onSurfaceVariant,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
  );
}

TextTheme _compactTextTheme(String fontFamily, ColorScheme scheme) => TextTheme(
  displayLarge: _style(fontFamily, 28, FontWeight.w500, scheme.onSurface, 1.15),
  displayMedium: _style(
    fontFamily,
    26,
    FontWeight.w500,
    scheme.onSurface,
    1.15,
  ),
  displaySmall: _style(fontFamily, 24, FontWeight.w500, scheme.onSurface, 1.2),
  headlineLarge: _style(fontFamily, 22, FontWeight.w500, scheme.onSurface, 1.2),
  headlineMedium: _style(
    fontFamily,
    20,
    FontWeight.w500,
    scheme.onSurface,
    1.2,
  ),
  headlineSmall: _style(fontFamily, 18, FontWeight.w500, scheme.onSurface, 1.2),
  titleLarge: _style(fontFamily, 20, FontWeight.w400, scheme.onSurface, 1.2),
  titleMedium: _style(fontFamily, 17, FontWeight.w500, scheme.onSurface, 1.25),
  titleSmall: _style(fontFamily, 15, FontWeight.w400, scheme.onSurface, 1.3),
  bodyLarge: _style(fontFamily, 16, FontWeight.w400, scheme.onSurface, 1.35),
  bodyMedium: _style(fontFamily, 14, FontWeight.w400, scheme.onSurface, 1.4),
  bodySmall: _style(
    fontFamily,
    13,
    FontWeight.w400,
    scheme.onSurfaceVariant,
    1.35,
  ),
  labelLarge: _style(fontFamily, 14, FontWeight.w500, scheme.onSurface, 1.25),
  labelMedium: _style(
    fontFamily,
    13,
    FontWeight.w400,
    scheme.onSurfaceVariant,
    1.25,
  ),
  labelSmall: _style(
    fontFamily,
    12,
    FontWeight.w400,
    scheme.onSurfaceVariant,
    1.25,
  ),
);

TextStyle _style(
  String family,
  double size,
  FontWeight weight,
  Color color,
  double height,
) => TextStyle(
  fontFamily: family,
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);
