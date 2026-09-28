import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_palette.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_line.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';
import 'package:quran_hifz/features/quran/presentation/mushaf/mushaf_renderer_message.dart';
import 'package:quran_hifz/features/quran/presentation/mushaf/mushaf_webview_driver.dart';
import 'package:quran_hifz/features/quran/presentation/mushaf/quran_strict_mushaf_surface.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/bismillah_v4_glyph.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';

void main() {

  testWidgets('surface ignores stale renderer events after generation changes', (
    tester,
  ) async {
    final metricEvents = <MushafPageMetricsEvent>[];
    ValueChanged<MushafRendererEvent>? firstEventSink;
    ValueChanged<MushafRendererEvent>? latestEventSink;
    ValueChanged<MushafWebViewDriver>? latestDriverReady;

    Widget buildSurface(int generation) {
      return MaterialApp(
        home: QuranStrictMushafSurface(
          page: const QcfMushafPage(
            page: 2,
            variant: QuranMushafVariant.qcfV4Tajweed,
            lines: [],
          ),
          palette: QuranMushafPalette.light,
          generation: generation,
          fontSize: 32,
          lineHeight: 1.35,
          showTajweedColors: true,
          pageFontUri: Uri.parse('asset:///page.woff2'),
          fontLoader: (_) async => const QuranStrictMushafFonts(
            pageFontBytes: [1],
            surahFontBytes: [2],
            bismillahFontBytes: [3],
            endMarkerFontBytes: [4],
          ),
          webViewBuilder: (key, onEvent, onDriverReady, onDiagnostic) {
            firstEventSink ??= onEvent;
            latestEventSink = onEvent;
            latestDriverReady = onDriverReady;
            return SizedBox(key: key);
          },
          onPageMetrics: metricEvents.add,
          onRetry: () {},
          onWordTap: (_, __) {},
          onWordLongPress: (_, __) {},
          onAyahTap: (_) {},
        ),
      );
    }

    await tester.pumpWidget(buildSurface(7));
    await tester.pump();
    await tester.pump();

    final driver = _RecordingMushafDriver();
    latestDriverReady!(driver);
    await tester.pump();
    expect(driver.renderedGenerations, [7]);

    firstEventSink!(
      const MushafPageMetricsEvent(
        page: 2,
        generation: 7,
        contentHeight: 700,
      ),
    );
    expect(metricEvents, hasLength(1));

    await tester.pumpWidget(buildSurface(8));
    await tester.pump();
    await tester.pump();

    firstEventSink!(
      const MushafPageMetricsEvent(
        page: 2,
        generation: 7,
        contentHeight: 999,
      ),
    );
    expect(metricEvents, hasLength(1));

    latestEventSink!(
      const MushafPageMetricsEvent(
        page: 2,
        generation: 8,
        contentHeight: 820,
      ),
    );
    expect(metricEvents.last.contentHeight, 820);
  });


  testWidgets('surface forwards continuous layout in the initial render payload', (
    tester,
  ) async {
    ValueChanged<MushafWebViewDriver>? driverReady;

    await tester.pumpWidget(
      MaterialApp(
        home: QuranStrictMushafSurface(
          page: const QcfMushafPage(
            page: 2,
            variant: QuranMushafVariant.qcfV4Tajweed,
            lines: [],
          ),
          palette: QuranMushafPalette.light,
          generation: 9,
          fontSize: 48,
          lineHeight: 1.8,
          showTajweedColors: true,
          continuousLayout: true,
          pageFontUri: Uri.parse('asset:///page.woff2'),
          fontLoader: (_) async => const QuranStrictMushafFonts(
            pageFontBytes: [1],
            surahFontBytes: [2],
            bismillahFontBytes: [3],
            endMarkerFontBytes: [4],
          ),
          webViewBuilder: (key, onEvent, onDriverReady, onDiagnostic) {
            driverReady = onDriverReady;
            return SizedBox(key: key);
          },
          onRetry: () {},
          onWordTap: (_, __) {},
          onWordLongPress: (_, __) {},
          onAyahTap: (_) {},
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final driver = _RecordingMushafDriver();
    driverReady!(driver);
    await tester.pump();

    expect(driver.payloads, hasLength(1));
    expect(driver.payloads.single.continuousLayout, isTrue);
    expect(driver.payloads.single.fontSize, 48);
    expect(driver.payloads.single.lineHeight, 1.8);
  });

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


class _RecordingMushafDriver implements MushafWebViewDriver {
  final renderedGenerations = <int>[];
  final payloads = <MushafRenderPayload>[];

  @override
  Future<void> loadRenderer() async {}

  @override
  Future<void> renderPage(MushafRenderPayload payload) async {
    renderedGenerations.add(payload.generation);
    payloads.add(payload);
  }

  @override
  Future<void> setPalette(QuranMushafPalette palette) async {}

  @override
  Future<void> setTypography({
    required double fontSize,
    required double lineHeight,
    required bool showTajweedColors,
  }) async {}

  @override
  Future<void> setActiveWord(
    String ayahKey,
    int wordPosition, {
    String? banglaMeaning,
  }) async {}

  @override
  Future<void> setActiveAyah(String ayahKey) async {}

  @override
  Future<void> setRange(String? startAyahKey, String? endAyahKey) async {}

  @override
  Future<void> clearPlaybackHighlight() async {}
}
