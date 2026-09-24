import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../quran/domain/quran_font_preference.dart';

class HifzAppearanceOverride {
  const HifzAppearanceOverride({this.font, this.fontSize, this.lineHeight});

  final QuranFontPreference? font;
  final double? fontSize;
  final double? lineHeight;

  HifzAppearanceOverride copyWith({
    QuranFontPreference? font,
    double? fontSize,
    double? lineHeight,
  }) => HifzAppearanceOverride(
    font: font ?? this.font,
    fontSize: fontSize ?? this.fontSize,
    lineHeight: lineHeight ?? this.lineHeight,
  );
}

final hifzAppearanceOverrideProvider =
    NotifierProvider<HifzAppearanceController, HifzAppearanceOverride>(
      HifzAppearanceController.new,
    );

class HifzAppearanceController extends Notifier<HifzAppearanceOverride> {
  @override
  HifzAppearanceOverride build() => const HifzAppearanceOverride();

  void setFont(QuranFontPreference value) {
    state = state.copyWith(font: value);
  }

  void setFontSize(double value) {
    state = state.copyWith(fontSize: value);
  }

  void setLineHeight(double value) {
    state = state.copyWith(lineHeight: value);
  }

  void reset() {
    state = const HifzAppearanceOverride(
      font: QuranFontPreference.defaultHifz,
      fontSize: 32,
      lineHeight: 1.35,
    );
  }
}
