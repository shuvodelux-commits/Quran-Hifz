import 'package:flutter/material.dart';

import '../domain/quran_font_preference.dart';
import '../domain/quran_script.dart';

/// Typography for Quran text only; application and translation text use Theme.
class QuranTextStyle {
  const QuranTextStyle._();

  static TextStyle forScript({
    required QuranScriptPreference script,
    required Color color,
    required double fontSize,
    required double lineHeight,
    QuranFontPreference? font,
    String? fontFamily,
    String? fontPackage,
  }) {
    return TextStyle(
      color: color,
      fontFamily: fontFamily ?? font?.fontFamily ?? script.preferredFontFamily,
      package: fontPackage,
      fontFamilyFallback: script.fontFamilyFallback,
      fontSize: fontSize,
      height: lineHeight,
      fontWeight: script == QuranScriptPreference.indoPak
          ? FontWeight.w400
          : FontWeight.w500,
    );
  }
}
