import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/audio/application/audio_providers.dart';
import 'package:quran_hifz/features/audio/application/quran_audio_controller.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_preset.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_controls_bar.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_reader_page.dart';
import 'package:quran_hifz/features/quran/application/quran_mushaf_providers.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_juz.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_font_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/domain/quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
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

Widget _readerApp() {
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
  }) async => null;

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
