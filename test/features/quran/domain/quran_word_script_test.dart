import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  test('word selects authentic text for the requested Quran script', () {
    const word = QuranWord(
      position: 1,
      arabic: 'UTHMANI',
      arabicIndopak: 'INDOPAK',
    );

    expect(word.arabicFor(QuranScriptPreference.uthmaniMadani), 'UTHMANI');
    expect(word.arabicFor(QuranScriptPreference.indoPak), 'INDOPAK');
  });

  test('IndoPak selection safely falls back for legacy content databases', () {
    const word = QuranWord(position: 1, arabic: 'UTHMANI');

    expect(word.arabicFor(QuranScriptPreference.indoPak), 'UTHMANI');
  });
}
