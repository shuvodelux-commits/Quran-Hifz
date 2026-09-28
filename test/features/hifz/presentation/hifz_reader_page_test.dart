import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/audio/application/audio_providers.dart';
import 'package:quran_hifz/features/audio/application/quran_audio_controller.dart';
import 'package:quran_hifz/features/audio/domain/playback_requests.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_preset.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reader_mode.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_continuous_reader.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_controls_bar.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_reader_page.dart';
import 'package:quran_hifz/features/quran/application/quran_mushaf_providers.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/application/reader_audio_actions.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_juz.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_font_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/domain/quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';
import 'package:quran_hifz/features/quran/presentation/mushaf/quran_strict_reader_body.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';

const _config = HifzSessionConfig(
  start: AyahRef(surahNumber: 1, ayahNumber: 1),
  end: AyahRef(surahNumber: 1, ayahNumber: 2),
  preset: HifzPresets.newMemorization,
);

void main() {
  testWidgets('reader uses compact Focused Mushaf chrome and selected range', (
    tester,
  ) async {
    await tester.pumpWidget(_readerApp());
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah 1–2'), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-reader-settings')), findsOneWidget);
    expect(find.byType(HifzControlsBar), findsOneWidget);
    expect(find.text('Audio & Hifz'), findsNothing);
    expect(find.text('Bookmarks'), findsNothing);
    expect(find.text('Translation'), findsNothing);

    final mushaf = tester.widget<QuranStrictReaderBody>(
      find.byType(QuranStrictReaderBody),
    );
    expect(mushaf.variant, QuranMushafVariant.qcfV4Tajweed);
    expect(mushaf.fontSize, 32);
    expect(mushaf.selectedStartAyahKey, '1:1');
    expect(mushaf.selectedEndAyahKey, '1:2');
    expect(mushaf.activeAyahKey, '1:1');
    expect(mushaf.activeWordPosition, 2);
    expect(mushaf.activeWordBanglaMeaning, 'পরম করুণাময়');
  });



  testWidgets('reader switches to Continuous without changing Hifz typography', (
    tester,
  ) async {
    await tester.pumpWidget(_readerApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HifzReaderPage)),
    );
    await container
        .read(appPreferencesControllerProvider.notifier)
        .setHifzFontSize(48);
    await container
        .read(appPreferencesControllerProvider.notifier)
        .setHifzLineHeight(1.8);
    await container
        .read(appPreferencesControllerProvider.notifier)
        .setHifzReaderMode(HifzReaderMode.continuous);
    await tester.pumpAndSettle();

    expect(find.byType(QuranStrictReaderBody), findsNothing);
    expect(find.byType(HifzContinuousReader), findsOneWidget);
    final continuous = tester.widget<HifzContinuousReader>(
      find.byType(HifzContinuousReader),
    );
    expect(continuous.fontSize, 48);
    expect(continuous.lineHeight, 1.8);
    expect(continuous.variant, QuranMushafVariant.qcfV4Tajweed);
  });

  testWidgets('playback meaning setting hides meaning but keeps active word', (
    tester,
  ) async {
    await tester.pumpWidget(_readerApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HifzReaderPage)),
    );
    await container
        .read(appPreferencesControllerProvider.notifier)
        .setShowPlaybackBanglaWordMeaning(false);
    await tester.pumpAndSettle();

    final mushaf = tester.widget<QuranStrictReaderBody>(
      find.byType(QuranStrictReaderBody),
    );
    expect(mushaf.activeAyahKey, '1:1');
    expect(mushaf.activeWordPosition, 2);
    expect(mushaf.activeWordBanglaMeaning, isNull);
  });

  testWidgets('repeat button edits and keeps the current Hifz pattern', (
    tester,
  ) async {
    await tester.pumpWidget(_readerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('hifz-repeat-pattern')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('hifz-pattern-ayah-3')));
    await tester.tap(find.byKey(const ValueKey('hifz-pattern-combined-2')));
    await tester.tap(find.byKey(const ValueKey('hifz-pattern-final-1')));
    await tester.tap(find.byKey(const ValueKey('hifz-pattern-pause-500')));
    await tester.ensureVisible(
      find.byKey(const ValueKey('hifz-pattern-save')),
    );
    await tester.tap(find.byKey(const ValueKey('hifz-pattern-save')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('hifz-repeat-pattern')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<ChoiceChip>(
        find.byKey(const ValueKey('hifz-pattern-ayah-3')),
      ).selected,
      isTrue,
    );
    expect(
      tester.widget<ChoiceChip>(
        find.byKey(const ValueKey('hifz-pattern-combined-2')),
      ).selected,
      isTrue,
    );
    expect(
      tester.widget<ChoiceChip>(
        find.byKey(const ValueKey('hifz-pattern-final-1')),
      ).selected,
      isTrue,
    );
    expect(
      tester.widget<ChoiceChip>(
        find.byKey(const ValueKey('hifz-pattern-pause-500')),
      ).selected,
      isTrue,
    );
  });

  testWidgets('word tap keeps the existing Quran pronunciation interaction', (
    tester,
  ) async {
    final port = _RecordingReaderAudioPort();
    final actions = ReaderAudioActions(
      repository: _FixtureQuranRepository(),
      resolver: _FixtureReaderPlaybackRequestResolver(),
      audio: port,
      translationResourceId: 1,
    );

    await tester.pumpWidget(_readerApp(readerAudioActions: actions));
    await tester.pumpAndSettle();

    final mushaf = tester.widget<QuranStrictReaderBody>(
      find.byType(QuranStrictReaderBody),
    );
    mushaf.onWordTap('1:1', 1);
    await tester.pump();
    await tester.pump();

    expect(port.wordRequests, hasLength(1));
    expect(port.wordRequests.single.wordKey, '1:1:1');
  });

  testWidgets('56px Hifz text remains selected on a narrow phone for both skins', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_readerApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HifzReaderPage)),
    );
    await container
        .read(appPreferencesControllerProvider.notifier)
        .setHifzFontSize(56);
    await container
        .read(appPreferencesControllerProvider.notifier)
        .setHifzMushafVariant(QuranMushafVariant.qcfV2);
    await tester.pumpAndSettle();

    var mushaf = tester.widget<QuranStrictReaderBody>(
      find.byType(QuranStrictReaderBody),
    );
    expect(mushaf.fontSize, 56);
    expect(mushaf.variant, QuranMushafVariant.qcfV2);
    expect(tester.takeException(), isNull);

    await container
        .read(appPreferencesControllerProvider.notifier)
        .setHifzMushafVariant(QuranMushafVariant.qcfV4Tajweed);
    await tester.pumpAndSettle();
    mushaf = tester.widget<QuranStrictReaderBody>(
      find.byType(QuranStrictReaderBody),
    );
    expect(mushaf.fontSize, 56);
    expect(mushaf.variant, QuranMushafVariant.qcfV4Tajweed);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hide/reveal keeps the Mushaf mounted and appearance keeps page', (
    tester,
  ) async {
    await tester.pumpWidget(_readerApp());
    await tester.pumpAndSettle();

    expect(find.byType(QuranStrictReaderBody), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('hifz-toggle-hidden')));
    await tester.pump();
    expect(find.byKey(const ValueKey('hifz-hidden-overlay')), findsOneWidget);
    expect(find.byType(QuranStrictReaderBody), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('hifz-toggle-hidden')));
    await tester.pump();
    expect(find.byKey(const ValueKey('hifz-hidden-overlay')), findsNothing);

    await tester.fling(
      find.byType(PageView),
      const Offset(-700, 0),
      1200,
    );
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('hifz-reader-settings')));
    await tester.pumpAndSettle();
    expect(find.text('QCF V4 Tajweed'), findsOneWidget);
    Navigator.of(tester.element(find.text('QCF V4 Tajweed'))).pop();
    await tester.pumpAndSettle();

    expect(find.text('2 / 2'), findsOneWidget);
  });
}

Widget _readerApp({ReaderAudioActions? readerAudioActions}) {
  return ProviderScope(
    overrides: [
      quranRepositoryProvider.overrideWithValue(_FixtureQuranRepository()),
      quranMushafPageRepositoryProvider.overrideWithValue(
        _FixtureMushafPageRepository(),
      ),
      quranPageFontRepositoryProvider.overrideWith(
        (ref, variant) => _UnavailablePageFontRepository(),
      ),
      appPreferencesRepositoryProvider.overrideWithValue(
        _MemoryPreferencesRepository(),
      ),
      quranAudioControllerProvider.overrideWith(_FixtureAudioController.new),
      if (readerAudioActions != null)
        readerAudioActionsProvider.overrideWithValue(readerAudioActions),
    ],
    child: const MaterialApp(
      home: HifzReaderPage(
        config: _config,
        initialPage: 1,
        planTitle: 'Al-Fatihah 1–2',
      ),
    ),
  );
}

class _FixtureAudioController extends QuranAudioController {
  @override
  QuranAudioState build() => const QuranAudioState(
    mode: QuranAudioMode.ayah,
    status: QuranAudioStatus.playing,
    speed: 1,
    repeatIndex: 1,
    repeatTotal: 5,
    ayahKey: '1:1',
    activeWordPosition: 2,
  );
}

class _FixtureQuranRepository implements QuranRepository {
  @override
  Future<List<QuranSurahSummary>> listSurahs() async => const [
    QuranSurahSummary(
      number: 1,
      nameArabic: 'الفاتحة',
      nameEnglish: 'Al-Fatihah',
      ayahCount: 7,
      pageStart: 1,
      pageEnd: 2,
      juzStart: 1,
    ),
  ];

  @override
  Future<List<QuranJuzSummary>> listJuzs() async => const [];

  @override
  Future<QuranAyah?> loadAyah({
    required int surahNumber,
    required int ayahNumber,
    required int translationResourceId,
  }) async {
    if (surahNumber != 1 || ayahNumber != 1) return null;
    return const QuranAyah(
      surahNumber: 1,
      ayahNumber: 1,
      pageNumber: 1,
      words: [
        QuranWord(
          position: 1,
          arabic: 'بِسْمِ',
          audioUrl: '001_001_001.mp3',
          banglaMeaning: 'নামে',
        ),
        QuranWord(
          position: 2,
          arabic: 'ٱلرَّحْمَٰنِ',
          audioUrl: '001_001_002.mp3',
          banglaMeaning: 'পরম করুণাময়',
        ),
      ],
    );
  }

  @override
  Future<QuranPageWindow> loadPageWindow({
    required int page,
    required int translationResourceId,
  }) async {
    return QuranPageWindow(
      page: page,
      ayahs: const [],
      previousPage: page == 1 ? null : page - 1,
      nextPage: page == 2 ? null : page + 1,
    );
  }
}

class _FixtureReaderPlaybackRequestResolver
    implements ReaderPlaybackRequestResolver {
  @override
  Future<WordPlaybackRequest> resolveWord(
    QuranAyah ayah,
    QuranWord word,
  ) async {
    return WordPlaybackRequest(
      source: 'https://example.test/word.mp3',
      wordKey: ayah.key + ':' + word.position.toString(),
      ayahKey: ayah.key,
      wordPosition: word.position,
    );
  }

  @override
  Future<AyahPlaybackRequest> resolveAyah(
    QuranAyah ayah, {
    required int repeatCount,
    required Duration pauseBetweenRepeats,
    required double speed,
  }) {
    throw UnimplementedError();
  }
}

class _RecordingReaderAudioPort implements ReaderAudioPort {
  final wordRequests = <WordPlaybackRequest>[];

  @override
  Future<void> playWord(WordPlaybackRequest request) async {
    wordRequests.add(request);
  }

  @override
  Future<void> playAyah(AyahPlaybackRequest request) async {}

  @override
  QuranAudioState readState() => const QuranAudioState.initial();

  @override
  Future<void> stop() async {}
}

class _FixtureMushafPageRepository implements QuranMushafPageRepository {
  @override
  Future<bool> isVariantAvailable(QuranMushafVariant variant) async => true;

  @override
  Future<QcfMushafPage> loadPage({
    required QuranMushafVariant variant,
    required int page,
  }) async {
    return QcfMushafPage(page: page, variant: variant, lines: const []);
  }
}

class _UnavailablePageFontRepository implements QuranPageFontRepository {
  @override
  Future<Uri> ensurePageFont(int page) async {
    throw QuranPageFontUnavailableException(
      page: page,
      message: 'offline fixture',
    );
  }

  @override
  Future<bool> isCached(int page) async => false;

  @override
  Future<void> prefetchNeighbors(int page) async {}
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
