import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/application/hifz_text_layout.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_line.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';

void main() {
  test('resolveMushafLine preserves cross-ayah order and verse-end flags', () {
    final window = QuranPageWindow(
      page: 1,
      previousPage: null,
      nextPage: 2,
      ayahs: const [
        QuranAyah(
          surahNumber: 1,
          ayahNumber: 1,
          words: [
            QuranWord(position: 1, arabic: 'أ'),
            QuranWord(position: 2, arabic: 'ب'),
          ],
        ),
        QuranAyah(
          surahNumber: 1,
          ayahNumber: 2,
          words: [
            QuranWord(position: 1, arabic: 'ج'),
            QuranWord(position: 2, arabic: 'د'),
          ],
        ),
      ],
    );
    final line = QuranMushafLine(
      lineNumber: 1,
      type: QuranMushafLineType.ayah,
      centered: false,
      surahNumber: 1,
      wordLocations: const [
        QuranWordLocation(surahNumber: 1, ayahNumber: 1, position: 2),
        QuranWordLocation(surahNumber: 1, ayahNumber: 2, position: 1),
      ],
    );

    final resolved = resolveMushafLine(window, line);

    expect(resolved.map((word) => word.location.toString()), [
      '1:1:2',
      '1:2:1',
    ]);
    expect(resolved.map((word) => word.endsAyah), [true, false]);
  });
}
