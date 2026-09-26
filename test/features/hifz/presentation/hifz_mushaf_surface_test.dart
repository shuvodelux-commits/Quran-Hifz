import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_hifz/features/audio/application/audio_providers.dart';
import 'package:quran_hifz/features/audio/domain/playback_requests.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_mushaf_surface.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_line.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';
import 'package:quran_hifz/features/quran/presentation/quran_reading_colors.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/quran_word_view.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';

import '../../../fakes/fake_audio_player_adapter.dart';

void main() {
  const surah = QuranSurahSummary(
    number: 67,
    nameArabic: 'الملك',
    nameEnglish: 'Al-Mulk',
    nameBangla: 'আল-মুলক',
    ayahCount: 30,
    pageStart: 562,
    pageEnd: 564,
    juzStart: 29,
  );
  const baqarah = QuranSurahSummary(
    number: 2,
    nameArabic: 'البقرة',
    nameEnglish: 'Al-Baqarah',
    ayahCount: 286,
    pageStart: 2,
    pageEnd: 49,
    juzStart: 1,
  );

  final window = QuranPageWindow(
    page: 562,
    previousPage: 561,
    nextPage: 563,
    ayahs: [
      QuranAyah(
        surahNumber: 67,
        ayahNumber: 1,
        pageNumber: 562,
        translation: 'TRANSLATION_MUST_NOT_RENDER',
        words: [
          QuranWord(position: 1, arabic: 'تَبَارَكَ'),
          QuranWord(position: 2, arabic: 'ٱلَّذِى'),
        ],
      ),
      QuranAyah(
        surahNumber: 67,
        ayahNumber: 2,
        pageNumber: 562,
        words: [
          QuranWord(position: 1, arabic: 'ٱلَّذِى'),
          QuranWord(position: 2, arabic: 'خَلَقَ'),
        ],
      ),
    ],
  );

  testWidgets('renders a readable Arabic-only fallback without row rules', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: SizedBox(
            width: 400,
            height: 700,
            child: HifzMushafSurface(surah: surah, window: window),
          ),
        ),
        preferences: const AppPreferences.defaults().copyWith(
          tapToShowBanglaWordMeaning: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الملك'), findsOneWidget);
    expect(find.text('تَبَارَكَ'), findsOneWidget);
    expect(find.text('خَلَقَ'), findsOneWidget);
    expect(find.text('Page 562'), findsOneWidget);
    expect(find.text('TRANSLATION_MUST_NOT_RENDER'), findsNothing);
    expect(find.byType(FittedBox), findsNothing);
    expect(find.byType(Card), findsNothing);
    expect(find.byKey(const ValueKey('surah-bismillah-67')), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-flow-line-0')), findsOneWidget);
    final firstLine = tester.widget<Container>(
      find.byKey(const ValueKey('hifz-flow-line-0')),
    );
    expect(firstLine.decoration, isNull);
    expect(find.byKey(const ValueKey('hifz-flow-richtext-0')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('hifz-flow-line-0')),
        matching: find.byType(Wrap),
      ),
      findsNothing,
    );

    final wordContext = tester.element(find.text('تَبَارَكَ'));
    final wordStyle = DefaultTextStyle.of(wordContext).style;
    expect(wordStyle.fontSize, greaterThanOrEqualTo(27));
  });

  testWidgets('ayah marker selects a Hifz range endpoint', (tester) async {
    AyahRef? selected;

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: HifzMushafSurface(
            surah: surah,
            window: window,
            onAyahSelected: (ayah) => selected = ayah,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('hifz-ayah-marker-67:2')));
    await tester.pump();

    expect(selected, const AyahRef(surahNumber: 67, ayahNumber: 2));
  });

  testWidgets('flow rows avoid whole-ayah boxes and active-ayah highlighting', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: HifzMushafSurface(
            surah: surah,
            window: window,
            selectedStartAyah: const AyahRef(surahNumber: 67, ayahNumber: 1),
            selectedEndAyah: const AyahRef(surahNumber: 67, ayahNumber: 2),
            activeAyahKey: '67:2',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('hifz-ayah-67:1')), findsNothing);
    expect(find.byKey(const ValueKey('hifz-ayah-67:2')), findsNothing);
    expect(find.byKey(const ValueKey('hifz-word-67:2:1')), findsOneWidget);
    expect(_wordColor(tester, '67:2', 1), isNot(QuranReadingColors.activeWord));
  });

  testWidgets('word taps move and clear the Hifz playback highlight', (
    tester,
  ) async {
    final player = FakeAudioPlayerAdapter(autoComplete: false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
          audioPlayerAdapterProvider.overrideWithValue(player),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final activeAyahKey = ref.watch(activeAyahPlaybackKeyProvider);
                return HifzMushafSurface(
                  surah: surah,
                  window: window,
                  activeAyahKey: activeAyahKey,
                  onWordTap: (ayah, word) {
                    unawaited(
                      ref
                          .read(quranAudioControllerProvider.notifier)
                          .playWord(
                            WordPlaybackRequest(
                              source: 'word-${ayah.key}-${word.position}.mp3',
                              wordKey: '${ayah.key}:${word.position}',
                              ayahKey: ayah.key,
                              wordPosition: word.position,
                            ),
                          ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HifzMushafSurface)),
    );

    await tester.tap(find.byKey(const ValueKey('hifz-word-67:1:1')));
    await tester.pumpAndSettle();
    expect(
      container.read(quranAudioControllerProvider).mode,
      QuranAudioMode.word,
    );
    expect(_wordColor(tester, '67:1', 1), QuranReadingColors.activeWord);
    expect(_wordColor(tester, '67:1', 2), isNot(QuranReadingColors.activeWord));
    expect(find.byKey(const ValueKey('hifz-ayah-67:1')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('hifz-word-67:1:2')));
    await tester.pumpAndSettle();
    expect(_wordColor(tester, '67:1', 1), isNot(QuranReadingColors.activeWord));
    expect(_wordColor(tester, '67:1', 2), QuranReadingColors.activeWord);

    player.completeCurrent();
    await tester.pumpAndSettle();
    expect(
      container.read(quranAudioControllerProvider).activeWordPosition,
      isNull,
    );
    expect(_wordColor(tester, '67:1', 1), isNot(QuranReadingColors.activeWord));
    expect(_wordColor(tester, '67:1', 2), isNot(QuranReadingColors.activeWord));
  });

  testWidgets('fallback Hifz words ignore regular-reader typography', (
    tester,
  ) async {
    final preferences = const AppPreferences.defaults().copyWith(
      quranFont: QuranFontPreference.qpcHafs,
      arabicFontSize: 20,
      arabicLineHeight: 1.2,
      hifzQuranFont: QuranFontPreference.indoPak,
      hifzFontSize: 34,
      hifzLineHeight: 1.8,
    );
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: Column(
            children: [
              Expanded(
                child: HifzMushafSurface(surah: surah, window: window),
              ),
              QuranWordView(
                key: ValueKey('reader-word-comparison'),
                word: QuranWord(position: 1, arabic: 'مِثَال'),
              ),
            ],
          ),
        ),
        preferences: preferences,
      ),
    );
    await tester.pumpAndSettle();

    final hifzWord = _wordStyle(tester, '67:1', 1);
    final readerWord = find.descendant(
      of: find.byKey(const ValueKey('reader-word-comparison')),
      matching: find.byType(Text),
    );
    final readerStyle = DefaultTextStyle.of(tester.element(readerWord)).style;
    expect(hifzWord.fontFamily, 'IndoPak Nastaleeq');
    expect(hifzWord.fontSize, 34);
    expect(hifzWord.height, 1.8);
    expect(readerStyle.fontFamily, 'QPC Hafs');
    expect(readerStyle.fontFamily, isNot(hifzWord.fontFamily));
    expect(readerStyle.fontSize, isNot(hifzWord.fontSize));
    expect(readerStyle.height, isNot(hifzWord.height));
  });

  testWidgets('no-line fallback keeps the legacy selected-Surah reflow', (
    tester,
  ) async {
    final mixedWindow = QuranPageWindow(
      page: 562,
      previousPage: 561,
      nextPage: 563,
      ayahs: [
        ...window.ayahs,
        const QuranAyah(
          surahNumber: 68,
          ayahNumber: 1,
          pageNumber: 562,
          words: [QuranWord(position: 1, arabic: 'نٓ')],
        ),
      ],
    );

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: HifzMushafSurface(surah: surah, window: mixedWindow),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تَبَارَكَ'), findsOneWidget);
    expect(find.text('نٓ'), findsNothing);
  });

  testWidgets(
    'canonical metadata fixes word membership and centers short Mushaf lines',
    (tester) async {
      final fixedWindow = QuranPageWindow(
        page: 562,
        previousPage: 561,
        nextPage: 563,
        ayahs: [
          ...window.ayahs,
          const QuranAyah(
            surahNumber: 68,
            ayahNumber: 1,
            pageNumber: 562,
            words: [QuranWord(position: 1, arabic: 'نٓ')],
          ),
        ],
        lines: [
          QuranMushafLine(
            lineNumber: 1,
            type: QuranMushafLineType.ayah,
            centered: true,
            surahNumber: 67,
            wordLocations: const [
              QuranWordLocation(surahNumber: 67, ayahNumber: 1, position: 1),
            ],
          ),
          QuranMushafLine(
            lineNumber: 2,
            type: QuranMushafLineType.ayah,
            centered: false,
            surahNumber: 67,
            wordLocations: const [
              QuranWordLocation(surahNumber: 67, ayahNumber: 1, position: 2),
              QuranWordLocation(surahNumber: 67, ayahNumber: 2, position: 1),
              QuranWordLocation(surahNumber: 67, ayahNumber: 2, position: 2),
            ],
          ),
          QuranMushafLine(
            lineNumber: 3,
            type: QuranMushafLineType.ayah,
            centered: false,
            surahNumber: 68,
            wordLocations: const [
              QuranWordLocation(surahNumber: 68, ayahNumber: 1, position: 1),
            ],
          ),
        ],
      );
      final preferences = const AppPreferences.defaults().copyWith(
        quranFont: QuranFontPreference.qpcHafs,
        hifzQuranFont: QuranFontPreference.indoPak,
        hifzFontSize: 40,
      );

      await tester.pumpWidget(
        _testApp(
          Scaffold(
            body: SizedBox(
              width: 320,
              height: 700,
              child: HifzMushafSurface(surah: surah, window: fixedWindow),
            ),
          ),
          preferences: preferences,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تَبَارَكَ'), findsOneWidget);
      expect(find.text('نٓ'), findsNothing);
      expect(_wordStyle(tester, '67:1', 1).fontFamily, 'IndoPak Nastaleeq');
      expect(_wordStyle(tester, '67:1', 1).fontSize, 40);
      expect(find.byKey(const ValueKey('hifz-flow-richtext-0')), findsNothing);
      expect(find.byKey(const ValueKey('hifz-line-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('hifz-line-2')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('hifz-line-1')),
          matching: find.byKey(const ValueKey('hifz-word-67:1:1')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('hifz-line-1')),
          matching: find.byKey(const ValueKey('hifz-word-67:1:2')),
        ),
        findsNothing,
      );
      final centeredLine = tester.widget<Wrap>(
        find.descendant(
          of: find.byKey(const ValueKey('hifz-line-1')),
          matching: find.byType(Wrap),
        ),
      );
      expect(centeredLine.alignment, WrapAlignment.center);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('hifz-line-2')),
          matching: find.byType(FittedBox),
        ),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('hifz-page-uniform-fit')), findsNothing);
      final markerRoot = find.byKey(const ValueKey('hifz-ayah-marker-67:2'));
      expect(
        find.descendant(of: markerRoot, matching: find.text('\u06dd')),
        findsNothing,
      );
      final marker = tester.widget<Text>(
        find.descendant(of: markerRoot, matching: find.text('٢')),
      );
      expect(marker.style!.fontFamily, 'packages/flutter_quran/hafs');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'canonical lines use one visible font scale across short and long lines',
    (tester) async {
      final words = <QuranWord>[
        const QuranWord(position: 1, arabic: 'هُدَى'),
        for (var position = 2; position <= 9; position++)
          QuranWord(position: position, arabic: 'مُسْتَقِيمٌ'),
      ];
      final fixedWindow = QuranPageWindow(
        page: 3,
        previousPage: 2,
        nextPage: 4,
        ayahs: [QuranAyah(surahNumber: 2, ayahNumber: 1, words: words)],
        lines: [
          QuranMushafLine(
            lineNumber: 1,
            type: QuranMushafLineType.ayah,
            centered: true,
            surahNumber: 2,
            wordLocations: [
              QuranWordLocation(surahNumber: 2, ayahNumber: 1, position: 1),
            ],
          ),
          QuranMushafLine(
            lineNumber: 2,
            type: QuranMushafLineType.ayah,
            centered: false,
            surahNumber: 2,
            wordLocations: [
              for (var position = 2; position <= 9; position++)
                QuranWordLocation(
                  surahNumber: 2,
                  ayahNumber: 1,
                  position: position,
                ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        _testApp(
          Scaffold(
            body: SizedBox(
              width: 320,
              height: 700,
              child: HifzMushafSurface(surah: baqarah, window: fixedWindow),
            ),
          ),
          preferences: const AppPreferences.defaults().copyWith(
            hifzFontSize: 56,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_wordStyle(tester, '2:1', 1).fontSize, 56);
      expect(_wordStyle(tester, '2:1', 2).fontSize, 56);
      expect(find.byKey(const ValueKey('hifz-page-uniform-fit')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'canonical Mushaf honors the selected Hifz font without fitting',
    (tester) async {
      final fixedWindow = QuranPageWindow(
        page: 3,
        previousPage: 2,
        nextPage: 4,
        ayahs: const [
          QuranAyah(
            surahNumber: 2,
            ayahNumber: 1,
            words: [
              QuranWord(position: 1, arabic: 'هُدَى', arabicIndopak: 'ہُدًی'),
            ],
          ),
        ],
        lines: [
          QuranMushafLine(
            lineNumber: 1,
            type: QuranMushafLineType.ayah,
            centered: true,
            surahNumber: 2,
            wordLocations: const [
              QuranWordLocation(surahNumber: 2, ayahNumber: 1, position: 1),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        _testApp(
          Scaffold(
            body: HifzMushafSurface(surah: baqarah, window: fixedWindow),
          ),
          preferences: const AppPreferences.defaults().copyWith(
            hifzQuranFont: QuranFontPreference.indoPak,
            hifzFontSize: 44,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final style = _wordStyle(tester, '2:1', 1);
      expect(style.fontFamily, 'IndoPak Nastaleeq');
      expect(style.fontSize, 44);
      expect(find.text('ہُدًی'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('hifz-line-1')),
          matching: find.byType(FittedBox),
        ),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('hifz-page-uniform-fit')), findsNothing);
    },
  );

  testWidgets(
    'flowing text retains word tap, long-press, and active-word behavior',
    (tester) async {
      final fixedWindow = QuranPageWindow(
        page: 562,
        previousPage: 561,
        nextPage: 563,
        ayahs: window.ayahs,
        lines: [
          QuranMushafLine(
            lineNumber: 1,
            type: QuranMushafLineType.ayah,
            centered: false,
            surahNumber: 67,
            wordLocations: const [
              QuranWordLocation(surahNumber: 67, ayahNumber: 1, position: 1),
              QuranWordLocation(surahNumber: 67, ayahNumber: 1, position: 2),
              QuranWordLocation(surahNumber: 67, ayahNumber: 2, position: 1),
              QuranWordLocation(surahNumber: 67, ayahNumber: 2, position: 2),
            ],
          ),
        ],
      );
      var taps = 0;
      var longPresses = 0;
      await tester.pumpWidget(
        _testApp(
          Scaffold(
            body: HifzMushafSurface(
              surah: surah,
              window: fixedWindow,
              activeAyahKey: '67:2',
              onWordTap: (_, __) => taps++,
              onWordLongPress: (_, __) => longPresses++,
            ),
          ),
          preferences: const AppPreferences.defaults().copyWith(
            tapToShowBanglaWordMeaning: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('hifz-word-67:1:1')));
      await tester.longPress(find.byKey(const ValueKey('hifz-word-67:2:1')));
      await tester.pumpAndSettle();

      expect(taps, 1);
      expect(longPresses, 1);
      expect(
        _wordColor(tester, '67:2', 1),
        isNot(QuranReadingColors.activeWord),
      );
    },
  );

  testWidgets('the first two Quran pages center every canonical line', (
    tester,
  ) async {
    final openingWindow = QuranPageWindow(
      page: 2,
      previousPage: 1,
      nextPage: 3,
      ayahs: const [
        QuranAyah(
          surahNumber: 2,
          ayahNumber: 1,
          words: [
            QuranWord(position: 1, arabic: 'الٓمّٓ'),
            QuranWord(position: 2, arabic: 'ذَٰلِكَ'),
          ],
        ),
      ],
      lines: [
        QuranMushafLine(
          lineNumber: 3,
          type: QuranMushafLineType.ayah,
          centered: false,
          surahNumber: 2,
          wordLocations: const [
            QuranWordLocation(surahNumber: 2, ayahNumber: 1, position: 1),
            QuranWordLocation(surahNumber: 2, ayahNumber: 1, position: 2),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: HifzMushafSurface(surah: baqarah, window: openingWindow),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final line = tester.widget<Wrap>(
      find.descendant(
        of: find.byKey(const ValueKey('hifz-line-3')),
        matching: find.byType(Wrap),
      ),
    );
    expect(line.alignment, WrapAlignment.center);
    expect(find.byKey(const ValueKey('hifz-page-uniform-fit')), findsNothing);
  });

  testWidgets('legacy fixed preference falls back to readable Free Flow', (
    tester,
  ) async {
    final words = List.generate(
      14,
      (index) => QuranWord(position: index + 1, arabic: 'مُسْتَقِيمٌ'),
    );
    final fixedWindow = QuranPageWindow(
      page: 562,
      previousPage: 561,
      nextPage: 563,
      ayahs: [QuranAyah(surahNumber: 67, ayahNumber: 1, words: words)],
      lines: [
        QuranMushafLine(
          lineNumber: 1,
          type: QuranMushafLineType.ayah,
          centered: false,
          surahNumber: 67,
          wordLocations: [
            for (var position = 1; position <= words.length; position++)
              QuranWordLocation(
                surahNumber: 67,
                ayahNumber: 1,
                position: position,
              ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: SizedBox(
            width: 320,
            height: 700,
            child: HifzMushafSurface(surah: surah, window: fixedWindow),
          ),
        ),
        preferences: const AppPreferences.defaults().copyWith(
          hifzLayoutMode: HifzLayoutMode.fixedMushaf,
          hifzFontSize: 56,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('hifz-fixed-paper')), findsNothing);
    expect(find.byKey(const ValueKey('hifz-line-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-flow-richtext-0')), findsNothing);
    expect(_wordStyle(tester, '67:1', 1).fontSize, 56);
    expect(tester.takeException(), isNull);
  });

  for (final (width, scale) in <(double, double)>[(320, 1.0), (360, 1.6)]) {
    testWidgets(
      'large Hifz text stays at 56 and wraps at $width with text scale $scale',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 700);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final words = List.generate(
          14,
          (index) => QuranWord(position: index + 1, arabic: 'مُسْتَقِيمٌ'),
        );
        final wideWindow = QuranPageWindow(
          page: 562,
          previousPage: 561,
          nextPage: 563,
          ayahs: [QuranAyah(surahNumber: 67, ayahNumber: 1, words: words)],
          lines: [
            QuranMushafLine(
              lineNumber: 1,
              type: QuranMushafLineType.ayah,
              centered: false,
              surahNumber: 67,
              wordLocations: [
                for (var position = 1; position <= words.length; position++)
                  QuranWordLocation(
                    surahNumber: 67,
                    ayahNumber: 1,
                    position: position,
                  ),
              ],
            ),
          ],
        );
        await tester.pumpWidget(
          _testApp(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                body: HifzMushafSurface(surah: surah, window: wideWindow),
              ),
            ),
            preferences: const AppPreferences.defaults().copyWith(
              hifzFontSize: 56,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final wordSizes = [
          for (var position = 1; position <= words.length; position++)
            _wordStyle(tester, '67:1', position).fontSize,
        ];
        expect(wordSizes.toSet(), hasLength(1));
        expect(wordSizes.toSet().single, 56);
        expect(
          tester
              .widget<SingleChildScrollView>(
                find.byKey(const ValueKey('hifz-mushaf-scroll-562')),
              )
              .scrollDirection,
          Axis.vertical,
        );
        expect(find.byKey(const ValueKey('hifz-line-1')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'invalid fixed records fall back instead of rendering partial lines',
    (tester) async {
      final malformed = QuranPageWindow(
        page: 562,
        previousPage: 561,
        nextPage: 563,
        ayahs: window.ayahs,
        lines: [
          QuranMushafLine(
            lineNumber: 2,
            type: QuranMushafLineType.ayah,
            centered: false,
            surahNumber: 67,
            wordLocations: const [
              QuranWordLocation(surahNumber: 67, ayahNumber: 1, position: 1),
              QuranWordLocation(surahNumber: 67, ayahNumber: 1, position: 1),
            ],
          ),
        ],
      );
      await tester.pumpWidget(
        _testApp(
          Scaffold(
            body: HifzMushafSurface(surah: surah, window: malformed),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('hifz-fixed-paper')), findsNothing);
      expect(find.byKey(const ValueKey('hifz-flow-line-0')), findsOneWidget);
    },
  );

  testWidgets('duplicate standalone Bismillah metadata falls back', (
    tester,
  ) async {
    final malformed = QuranPageWindow(
      page: 1,
      previousPage: null,
      nextPage: 2,
      ayahs: const [
        QuranAyah(
          surahNumber: 2,
          ayahNumber: 1,
          words: [QuranWord(position: 1, arabic: 'الٓمّٓ')],
        ),
      ],
      lines: [
        QuranMushafLine(
          lineNumber: 1,
          type: QuranMushafLineType.bismillah,
          centered: true,
          surahNumber: 2,
        ),
        QuranMushafLine(
          lineNumber: 2,
          type: QuranMushafLineType.bismillah,
          centered: true,
          surahNumber: 2,
        ),
        QuranMushafLine(
          lineNumber: 3,
          type: QuranMushafLineType.ayah,
          centered: false,
          surahNumber: 2,
          wordLocations: const [
            QuranWordLocation(surahNumber: 2, ayahNumber: 1, position: 1),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: HifzMushafSurface(surah: baqarah, window: malformed),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('hifz-fixed-paper')), findsNothing);
    expect(find.byKey(const ValueKey('hifz-flow-line-0')), findsOneWidget);
  });

  testWidgets('flowing Bismillah and ornaments follow the canonical policy', (
    tester,
  ) async {
    final policyWindow = QuranPageWindow(
      page: 1,
      previousPage: null,
      nextPage: 2,
      ayahs: const [
        QuranAyah(
          surahNumber: 2,
          ayahNumber: 1,
          words: [QuranWord(position: 1, arabic: 'الٓمّٓ')],
        ),
      ],
      lines: [
        QuranMushafLine(
          lineNumber: 1,
          type: QuranMushafLineType.bismillah,
          centered: true,
          surahNumber: 2,
        ),
        QuranMushafLine(
          lineNumber: 2,
          type: QuranMushafLineType.ayah,
          centered: false,
          surahNumber: 1,
          wordLocations: const [
            QuranWordLocation(surahNumber: 1, ayahNumber: 1, position: 1),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: HifzMushafSurface(surah: baqarah, window: policyWindow),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('surah-bismillah-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('surah-bismillah-9')), findsNothing);
    expect(find.byKey(const ValueKey('hifz-ayah-marker-2:1')), findsOneWidget);
    final markerRoot = find.byKey(const ValueKey('hifz-ayah-marker-2:1'));
    expect(
      find.descendant(of: markerRoot, matching: find.text('\u06dd')),
      findsNothing,
    );
    final digit = tester.widget<Text>(
      find.descendant(of: markerRoot, matching: find.text('١')),
    );
    expect(digit.style!.fontFamily, 'packages/flutter_quran/hafs');
  });

  testWidgets('Al-Fatihah promotes ayah one to one centered Bismillah', (
    tester,
  ) async {
    const fatihah = QuranSurahSummary(
      number: 1,
      nameArabic: 'الفاتحة',
      nameEnglish: 'Al-Fatihah',
      ayahCount: 7,
      pageStart: 1,
      pageEnd: 1,
      juzStart: 1,
    );
    final fatihahWindow = QuranPageWindow(
      page: 1,
      previousPage: null,
      nextPage: 2,
      ayahs: const [
        QuranAyah(
          surahNumber: 1,
          ayahNumber: 1,
          words: [
            QuranWord(position: 1, arabic: 'بِسْمِ'),
            QuranWord(position: 2, arabic: 'اللَّهِ'),
          ],
        ),
        QuranAyah(
          surahNumber: 1,
          ayahNumber: 2,
          words: [QuranWord(position: 1, arabic: 'الْحَمْدُ')],
        ),
      ],
    );

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: HifzMushafSurface(surah: fatihah, window: fatihahWindow),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('surah-bismillah-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-word-1:1:1')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-ayah-marker-1:1')), findsNothing);
    expect(find.byKey(const ValueKey('hifz-word-1:2:1')), findsOneWidget);
  });

  testWidgets('Hifz long press opens details callback without word audio tap', (
    tester,
  ) async {
    var taps = 0;
    var details = 0;
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: HifzMushafSurface(
            surah: surah,
            window: window,
            onWordTap: (ayah, word) => taps++,
            onWordLongPress: (ayah, word) => details++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const ValueKey('hifz-word-67:1:1')));
    await tester.pumpAndSettle();
    expect(details, 1);
    expect(taps, 0);
  });
}

Color? _wordColor(WidgetTester tester, String ayahKey, int position) {
  return _wordStyle(tester, ayahKey, position).color;
}

TextStyle _wordStyle(WidgetTester tester, String ayahKey, int position) {
  final word = find.byKey(ValueKey('hifz-word-$ayahKey:$position'));
  final text = find.descendant(of: word, matching: find.byType(Text)).first;
  return DefaultTextStyle.of(tester.element(text)).style;
}

Widget _testApp(Widget home, {AppPreferences? preferences}) {
  return ProviderScope(
    overrides: [
      appPreferencesRepositoryProvider.overrideWithValue(
        _MemoryPreferencesRepository()
          ..value = preferences ?? const AppPreferences.defaults(),
      ),
    ],
    child: MaterialApp(home: home),
  );
}

class _MemoryPreferencesRepository implements AppPreferencesRepository {
  AppPreferences value = const AppPreferences.defaults();

  @override
  Future<AppPreferences> load() async => value;

  @override
  Future<void> save(AppPreferences preferences) async {
    value = preferences;
  }
}
