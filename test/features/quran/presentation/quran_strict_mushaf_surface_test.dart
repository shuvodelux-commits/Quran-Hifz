import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_palette.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_line.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';
import 'package:quran_hifz/features/quran/presentation/mushaf/quran_strict_mushaf_surface.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/bismillah_v4_glyph.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';

void main() {
  testWidgets(
    'font failure falls back to readable Unicode page with identity and retry',
    (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: QuranStrictMushafSurface(
            page: const QcfMushafPage(
              page: 440,
              variant: QuranMushafVariant.qcfV4Tajweed,
              lines: [],
            ),
            palette: QuranMushafPalette.light,
            generation: 1,
            fontSize: 32,
            lineHeight: 1.35,
            showTajweedColors: true,
            pageFontUri: Uri.parse('file:///missing.woff2'),
            fallbackWindow: _page440(),
            fontLoader: (_) async => throw StateError('offline'),
            onRetry: () => retries++,
            onWordTap: (_, __) {},
            onWordLongPress: (_, __) {},
            onAyahTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('سورة 36'), findsOneWidget);
      expect(find.byType(BismillahV4Glyph), findsOneWidget);
      expect(find.textContaining('يس'), findsOneWidget);
      expect(find.text('Page 440'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retries, 1);
    },
  );
}

QuranPageWindow _page440() => QuranPageWindow(
  page: 440,
  previousPage: 439,
  nextPage: 441,
  ayahs: const [
    QuranAyah(
      surahNumber: 36,
      ayahNumber: 1,
      pageNumber: 440,
      words: [QuranWord(position: 1, arabic: 'يس')],
    ),
  ],
  lines: [
    QuranMushafLine(
      lineNumber: 4,
      type: QuranMushafLineType.surahName,
      centered: true,
      surahNumber: 36,
    ),
    QuranMushafLine(
      lineNumber: 5,
      type: QuranMushafLineType.bismillah,
      centered: true,
      surahNumber: 36,
    ),
    QuranMushafLine(
      lineNumber: 6,
      type: QuranMushafLineType.ayah,
      centered: false,
      surahNumber: 36,
      wordLocations: const [
        QuranWordLocation(surahNumber: 36, ayahNumber: 1, position: 1),
      ],
    ),
  ],
);
