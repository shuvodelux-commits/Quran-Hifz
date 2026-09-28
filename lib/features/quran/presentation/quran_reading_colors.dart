import 'package:flutter/material.dart';

import '../domain/tajweed_segment.dart';
import '../../../core/theme/app_palette.dart';

/// Quran-reading colors kept in one place for consistent Quran study UI.
abstract final class QuranReadingColors {
  /// Sampled from the user's approved reading reference.
  ///
  /// Both sentence playback and tap-to-play word audio use this same word-only
  /// emphasis. The surrounding ayah remains unchanged.
  static const activeWord = Color(0xFF087EAB);

  static Color activeWordFor(BuildContext context) {
    final accent = Theme.of(context).extension<AppPalette>()?.readerAccent;
    if (accent == null) return activeWord;

    final hsv = HSVColor.fromColor(accent);
    return hsv
        .withSaturation((hsv.saturation + 0.18).clamp(0.0, 1.0).toDouble())
        .withValue((hsv.value + 0.18).clamp(0.0, 1.0).toDouble())
        .toColor();
  }

  /// Classic Tajweed palette for the Quran Foundation embedded rule classes.
  /// Dark mode uses brighter equivalents while preserving rule distinctions.
  static Color? tajweedColor(TajweedRule? rule, Brightness brightness) {
    if (rule == null) return null;

    final dark = brightness == Brightness.dark;
    return switch (rule) {
      TajweedRule.hamWasl || TajweedRule.silent || TajweedRule.laamShamsiyah =>
        dark ? const Color(0xFFB8B8B8) : const Color(0xFFAAAAAA),
      TajweedRule.maddaNormal =>
        dark ? const Color(0xFF7FA0FF) : const Color(0xFF537FFF),
      TajweedRule.maddaPermissible =>
        dark ? const Color(0xFF7380FF) : const Color(0xFF4050FF),
      TajweedRule.maddaNecessary =>
        dark ? const Color(0xFF6A78FF) : const Color(0xFF000EBC),
      TajweedRule.maddaObligatory =>
        dark ? const Color(0xFF6E8EFF) : const Color(0xFF2144C1),
      TajweedRule.qalqalah =>
        dark ? const Color(0xFFFF5960) : const Color(0xFFDD0008),
      TajweedRule.ikhfaShafawi =>
        dark ? const Color(0xFFFF66E5) : const Color(0xFFD500B7),
      TajweedRule.ikhfa =>
        dark ? const Color(0xFFD273E2) : const Color(0xFF9400A8),
      TajweedRule.iqlab =>
        dark ? const Color(0xFF70D7FF) : const Color(0xFF26BFFD),
      TajweedRule.idghamShafawi =>
        dark ? const Color(0xFF79DC56) : const Color(0xFF58B800),
      TajweedRule.idghamWithGhunnah =>
        dark ? const Color(0xFF49C5A4) : const Color(0xFF169777),
      TajweedRule.idghamWithoutGhunnah =>
        dark ? const Color(0xFF60C65F) : const Color(0xFF169200),
      TajweedRule.idghamMutajaanisain || TajweedRule.idghamMutaqaaribain =>
        dark ? const Color(0xFFC4C4C4) : const Color(0xFFA1A1A1),
      TajweedRule.ghunnah =>
        dark ? const Color(0xFFFFA35C) : const Color(0xFFFF7E1E),
    };
  }
}
