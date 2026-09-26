import 'quran_font_preference.dart';

enum QuranMushafVariant {
  qcfV2(mushafId: 1),
  qcfV4Tajweed(mushafId: 19);

  const QuranMushafVariant({required this.mushafId});

  final int mushafId;
  int get pageCount => 604;

  QuranFontPreference get fontPreference => switch (this) {
    QuranMushafVariant.qcfV2 => QuranFontPreference.qcfV2,
    QuranMushafVariant.qcfV4Tajweed => QuranFontPreference.qcfV4Tajweed,
  };
}

extension QuranFontPreferenceMushafVariant on QuranFontPreference {
  QuranMushafVariant? get mushafVariant => switch (this) {
    QuranFontPreference.qcfV2 => QuranMushafVariant.qcfV2,
    QuranFontPreference.qcfV4Tajweed => QuranMushafVariant.qcfV4Tajweed,
    QuranFontPreference.qpcHafs || QuranFontPreference.indoPak => null,
  };
}
