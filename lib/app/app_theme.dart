import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/theme/reference_colors.dart';
import '../features/settings/domain/app_preferences.dart';

ThemeData appTheme(
  AppThemePreference preference, {
  AppLanguage language = AppLanguage.bangla,
  double uiFontScale = 1.0,
  double uiLineHeightScale = 1.0,
}) {
  final dark = preference == AppThemePreference.dark;
  final seed = switch (preference) {
    AppThemePreference.green => const Color(0xFF397A65),
    AppThemePreference.women => const Color(0xFFA75E7B),
    AppThemePreference.dark => const Color(0xFF55BBC2),
    _ => ReferenceColors.appBlue,
  };
  var scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: dark ? Brightness.dark : Brightness.light,
  );
  if (!dark && preference == AppThemePreference.light) {
    scheme = scheme.copyWith(
      primary: ReferenceColors.appBlue,
      onPrimary: Colors.white,
      primaryContainer: ReferenceColors.blueTint,
      onPrimaryContainer: const Color(0xFF172126),
      secondary: ReferenceColors.deepBlue,
      onSecondary: Colors.white,
      secondaryContainer: ReferenceColors.blueTint,
      onSecondaryContainer: const Color(0xFF172126),
      tertiary: ReferenceColors.appBlue,
      onTertiary: Colors.white,
      tertiaryContainer: ReferenceColors.blueTint,
      onTertiaryContainer: const Color(0xFF172126),
      error: const Color(0xFFB94A52),
      surface: ReferenceColors.warmCanvas,
      onSurface: const Color(0xFF172126),
      onSurfaceVariant: const Color(0xFF667178),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: ReferenceColors.cardSurface,
      surfaceContainer: const Color(0xFFF2F1EC),
      surfaceContainerHigh: const Color(0xFFECEAE4),
      surfaceContainerHighest: const Color(0xFFE1DED5),
      outline: const Color(0xFF8B9599),
      outlineVariant: const Color(0xFFE6E8E8),
      inverseSurface: const Color(0xFF172126),
      onInverseSurface: Colors.white,
      inversePrimary: const Color(0xFF9CC4CF),
    );
  }

  final androidTypography = Typography.material2021(
    platform: TargetPlatform.android,
    colorScheme: scheme,
  );
  final fontFamily = language == AppLanguage.bangla ? 'SolaimanLipi' : null;
  final baseTextTheme = language == AppLanguage.bangla
      ? _compactTextTheme('SolaimanLipi', scheme)
      : androidTypography.englishLike.apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
          decorationColor: scheme.onSurface,
        );
  final textTheme = _withUiLineHeight(
    baseTextTheme.apply(fontSizeFactor: uiFontScale),
    uiLineHeightScale,
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
        readerAccent: scheme.primary,
        accentPressed: preference == AppThemePreference.light
            ? ReferenceColors.deepBlue
            : scheme.secondary,
        accentTint: scheme.primaryContainer,
        cardSurface: scheme.surfaceContainerLow,
        secondaryText: scheme.onSurfaceVariant,
        subtleBorder: scheme.outlineVariant,
        quranHeader: preference == AppThemePreference.light
            ? ReferenceColors.quranCardBlue
            : scheme.primary,
        goldAccent: preference == AppThemePreference.light
            ? ReferenceColors.goldAccent
            : scheme.tertiary,
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
      height: 62,
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
      dense: true,
      minTileHeight: 44,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      iconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      titleTextStyle: textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: textTheme.bodySmall,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainer,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
  displayLarge: _style(fontFamily, 32, FontWeight.w600, scheme.onSurface, 1.15),
  displayMedium: _style(
    fontFamily,
    28,
    FontWeight.w600,
    scheme.onSurface,
    1.15,
  ),
  displaySmall: _style(fontFamily, 24, FontWeight.w600, scheme.onSurface, 1.2),
  headlineLarge: _style(fontFamily, 22, FontWeight.w600, scheme.onSurface, 1.2),
  headlineMedium: _style(
    fontFamily,
    20,
    FontWeight.w600,
    scheme.onSurface,
    1.2,
  ),
  headlineSmall: _style(fontFamily, 18, FontWeight.w600, scheme.onSurface, 1.2),
  titleLarge: _style(fontFamily, 20, FontWeight.w600, scheme.onSurface, 1.2),
  titleMedium: _style(fontFamily, 16, FontWeight.w600, scheme.onSurface, 1.25),
  titleSmall: _style(fontFamily, 14, FontWeight.w500, scheme.onSurface, 1.3),
  bodyLarge: _style(fontFamily, 15, FontWeight.w400, scheme.onSurface, 1.4),
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
    FontWeight.w500,
    scheme.onSurfaceVariant,
    1.25,
  ),
  labelSmall: _style(
    fontFamily,
    12,
    FontWeight.w500,
    scheme.onSurfaceVariant,
    1.25,
  ),
);

/// Adjusts UI text metrics only; Quran and Hifz have their own explicit
/// typography settings and are not derived from this TextTheme.
TextTheme _withUiLineHeight(TextTheme base, double factor) {
  if (factor == 1.0) return base;
  TextStyle? scaled(TextStyle? style) =>
      style == null
          ? null
          : style.copyWith(height: (style.height ?? 1.3) * factor);
  return TextTheme(
    displayLarge: scaled(base.displayLarge),
    displayMedium: scaled(base.displayMedium),
    displaySmall: scaled(base.displaySmall),
    headlineLarge: scaled(base.headlineLarge),
    headlineMedium: scaled(base.headlineMedium),
    headlineSmall: scaled(base.headlineSmall),
    titleLarge: scaled(base.titleLarge),
    titleMedium: scaled(base.titleMedium),
    titleSmall: scaled(base.titleSmall),
    bodyLarge: scaled(base.bodyLarge),
    bodyMedium: scaled(base.bodyMedium),
    bodySmall: scaled(base.bodySmall),
    labelLarge: scaled(base.labelLarge),
    labelMedium: scaled(base.labelMedium),
    labelSmall: scaled(base.labelSmall),
  );
}

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
