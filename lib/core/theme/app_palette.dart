import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.readerAccent,
    required this.accentPressed,
    required this.accentTint,
    required this.cardSurface,
    required this.secondaryText,
    required this.subtleBorder,
    required this.quranHeader,
    required this.goldAccent,
  });

  final Color readerAccent;
  final Color accentPressed;
  final Color accentTint;
  final Color cardSurface;
  final Color secondaryText;
  final Color subtleBorder;
  final Color quranHeader;
  final Color goldAccent;

  @override
  AppPalette copyWith({
    Color? readerAccent,
    Color? accentPressed,
    Color? accentTint,
    Color? cardSurface,
    Color? secondaryText,
    Color? subtleBorder,
    Color? quranHeader,
    Color? goldAccent,
  }) => AppPalette(
    readerAccent: readerAccent ?? this.readerAccent,
    accentPressed: accentPressed ?? this.accentPressed,
    accentTint: accentTint ?? this.accentTint,
    cardSurface: cardSurface ?? this.cardSurface,
    secondaryText: secondaryText ?? this.secondaryText,
    subtleBorder: subtleBorder ?? this.subtleBorder,
    quranHeader: quranHeader ?? this.quranHeader,
    goldAccent: goldAccent ?? this.goldAccent,
  );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      readerAccent:
          Color.lerp(readerAccent, other.readerAccent, t) ?? readerAccent,
      accentPressed:
          Color.lerp(accentPressed, other.accentPressed, t) ?? accentPressed,
      accentTint: Color.lerp(accentTint, other.accentTint, t) ?? accentTint,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t) ?? cardSurface,
      secondaryText:
          Color.lerp(secondaryText, other.secondaryText, t) ?? secondaryText,
      subtleBorder:
          Color.lerp(subtleBorder, other.subtleBorder, t) ?? subtleBorder,
      quranHeader: Color.lerp(quranHeader, other.quranHeader, t) ?? quranHeader,
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t) ?? goldAccent,
    );
  }
}
