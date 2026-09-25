import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/core/theme/app_palette.dart';
import 'package:quran_hifz/features/audio/application/audio_providers.dart';
import 'package:quran_hifz/features/audio/application/quran_audio_controller.dart';
import 'package:quran_hifz/features/audio/domain/playback_requests.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/application/reader_audio_actions.dart';
import 'package:quran_hifz/features/quran/application/reader_controller.dart';
import 'package:quran_hifz/features/quran/data/bengali_word_meanings.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_juz.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/domain/quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';
import 'package:quran_hifz/features/quran/presentation/quran_reader_page.dart';
import 'package:quran_hifz/features/quran/presentation/quran_reading_colors.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';
import 'package:quran_hifz/features/study/application/study_controller.dart';
import 'package:quran_hifz/features/study/application/study_providers.dart';
import 'package:quran_hifz/features/study/domain/bookmark.dart';
import 'package:quran_hifz/features/study/domain/note.dart';
import 'package:quran_hifz/features/study/domain/study_repository.dart';

import '../../../fakes/fake_audio_player_adapter.dart';

const _surah = QuranSurahSummary(
  number: 1,
  nameArabic: 'الفاتحة',
  nameEnglish: 'Al-Fatihah',
  nameBangla: null,
  revelationPlace: 'Makkah',
  ayahCount: 2,
  pageStart: 1,
  pageEnd: 2,
  juzStart: 1,
);

void main() {
  testWidgets('reader shows a localized Surah information header', (
    tester,
  ) async {
    await tester.pumpWidget(_readerApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('reader-surah-header')), findsOneWidget);
    expect(find.textContaining('আল-ফাতিহা'), findsWidgets);
    expect(find.textContaining('আয়াত'), findsOneWidget);
    expect(find.textContaining('Makkah'), findsOneWidget);
    expect(find.textContaining('English'), findsOneWidget);
    expect(find.byTooltip('Play Surah'), findsOneWidget);
    expect(find.byTooltip('Open Tafsir'), findsOneWidget);
    expect(find.byTooltip('Downloads'), findsOneWidget);
  });

  testWidgets('Surah information card uses Quran blue and calligraphic name', (
    tester,
  ) async {
    final theme = appTheme(
      AppThemePreference.light,
      language: AppLanguage.bangla,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(),
        child: MaterialApp(
          theme: theme,
          home: const QuranReaderPage(surah: _surah),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final card = tester.widget<Container>(
      find.byKey(const ValueKey('reader-surah-info-card')),
    );
    final decoration = card.decoration! as BoxDecoration;
    expect(decoration.color, theme.extension<AppPalette>()!.quranHeader);

    final arabic = tester.widget<Text>(find.text('surah001'));
    expect(arabic.style?.fontFamily, 'SurahNameV4');
    expect(find.byTooltip('Play Surah'), findsOneWidget);
    expect(find.byTooltip('Open Tafsir'), findsOneWidget);
    expect(find.byTooltip('Downloads'), findsOneWidget);
  });

  testWidgets('QUL reader ligature keeps the Arabic Surah name in semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_readerApp());
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('سورة الفاتحة')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('surah001')), findsNothing);
    semantics.dispose();
  });

  testWidgets('compact reader top bar stays fixed while verses scroll', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_readerApp());
    await tester.pumpAndSettle();

    final topBar = find.byKey(const ValueKey('reader-top-bar'));
    expect(topBar, findsOneWidget);
    expect(find.byKey(const ValueKey('reader-surah-navigation')), findsNothing);
    expect(find.text('১. আল-ফাতিহা'), findsOneWidget);
    expect(find.byTooltip('Bookmarks'), findsOneWidget);
    expect(find.byTooltip('Reader settings'), findsOneWidget);
    final before = tester.getTopLeft(topBar);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(topBar), before);
    expect(tester.getSize(topBar).height, lessThanOrEqualTo(58));
    expect(find.byKey(const ValueKey('reader-surah-header')), findsNothing);
  });

  testWidgets('reader title opens the Surah chooser', (tester) async {
    await tester.pumpWidget(_readerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('reader-surah-title')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('reader-surah-navigation')),
      findsOneWidget,
    );
    expect(find.text('১. আল-ফাতিহা'), findsWidgets);
  });

  testWidgets('reader shows the reference action bar and tapped word meaning', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._overrides(),
          readerPlaybackRequestResolverProvider.overrideWithValue(
            _WordFixtureResolver(),
          ),
          audioPlayerAdapterProvider.overrideWithValue(
            FakeAudioPlayerAdapter(autoComplete: false),
          ),
        ],
        child: const MaterialApp(home: QuranReaderPage(surah: _surah)),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(find.byTooltip('Play ayah'), findsWidgets);
    expect(find.byTooltip('Favorite ayah'), findsWidgets);
    expect(find.byTooltip('Bookmark ayah'), findsWidgets);
    expect(find.byTooltip('Share ayah'), findsWidgets);
    expect(find.byTooltip('Copy ayah'), findsWidgets);

    await tester.tap(find.text('A'));
    await tester.pump();
    expect(find.text('Fixture meaning'), findsOneWidget);
  });

  testWidgets('ayah control changes to Stop while its audio is active', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._overrides(),
          quranAudioControllerProvider.overrideWith(_PlayingAyahController.new),
          readerAudioActionsProvider.overrideWith((ref) {
            final controller = ref.read(quranAudioControllerProvider.notifier);
            return ReaderAudioActions(
              repository: _ReaderFixtureRepository(),
              resolver: _WordFixtureResolver(),
              audio: QuranControllerReaderAudioPort(
                playWord: (_) async {},
                playAyah: (_) async {},
                stop: controller.stop,
                readState: () => ref.read(quranAudioControllerProvider),
              ),
              translationResourceId: 1,
            );
          }),
        ],
        child: const MaterialApp(home: QuranReaderPage(surah: _surah)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Stop ayah'), findsOneWidget);
    await tester.tap(find.byTooltip('Stop ayah'));
    await tester.pump();
    expect(find.byTooltip('Play ayah'), findsWidgets);
  });

  testWidgets('minimized player stays minimized when the next ayah starts', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._overrides(),
          quranAudioControllerProvider.overrideWith(_PlayingAyahController.new),
        ],
        child: const MaterialApp(home: QuranReaderPage(surah: _surah)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('reader-playback-panel')), findsOneWidget);
    await tester.tap(find.byTooltip('Minimize player'));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('reader-minimized-player')),
      findsOneWidget,
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(QuranReaderPage)),
    );
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _PlayingAyahController;
    controller.nextFixtureAyah();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('reader-minimized-player')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('reader-playback-panel')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('reader-minimized-player')));
    await tester.pump();
    expect(find.byKey(const ValueKey('reader-playback-panel')), findsOneWidget);
  });

  testWidgets('ayah playback options opens the unified player, not a sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._overrides(),
          quranAudioControllerProvider.overrideWith(_PlayingAyahController.new),
        ],
        child: const MaterialApp(home: QuranReaderPage(surah: _surah)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Minimize player'));
    await tester.pump();

    await tester.tap(find.byTooltip('Playback options').first);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('reader-playback-panel')), findsOneWidget);
    expect(find.text('Playback options'), findsNothing);
  });

  testWidgets('word with no bundled gloss loads a Bengali popup', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._overrides(),
          bengaliWordMeaningsProvider.overrideWithValue(
            _FixtureBengaliMeanings(),
          ),
          readerPlaybackRequestResolverProvider.overrideWithValue(
            _WordFixtureResolver(),
          ),
          audioPlayerAdapterProvider.overrideWithValue(
            FakeAudioPlayerAdapter(autoComplete: false),
          ),
        ],
        child: const MaterialApp(home: QuranReaderPage(surah: _surah)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('দ্বিতীয়'), findsOneWidget);
  });

  testWidgets('reader renders selected Surah words in canonical RTL order', (
    tester,
  ) async {
    await tester.pumpWidget(_readerApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('ayah-1:1')), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);

    final first = tester.getTopLeft(find.text('A'));
    final second = tester.getTopLeft(find.text('B'));
    expect(first.dx, greaterThan(second.dx));
  });

  testWidgets(
    'reader never renders an adjacent Surah from a mixed boundary page',
    (tester) async {
      await tester.pumpWidget(_readerApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('ayah-1:1')), findsOneWidget);
      expect(find.byKey(const ValueKey('ayah-1:2')), findsOneWidget);
      expect(find.byKey(const ValueKey('ayah-2:1')), findsNothing);
      expect(find.text('Adjacent Surah translation'), findsNothing);
    },
  );

  testWidgets('reader settings keeps translation controls reachable', (
    tester,
  ) async {
    await tester.pumpWidget(_readerApp());
    await tester.pumpAndSettle();

    expect(find.text('Fixture Bangla translation 1'), findsOneWidget);
    expect(find.byTooltip('Hide translation'), findsNothing);
    await tester.tap(find.byTooltip('Reader settings'));
    await tester.pumpAndSettle();

    expect(find.text('সেটিংস'), findsOneWidget);
    expect(find.text('অনুবাদ দেখান'), findsOneWidget);
  });

  testWidgets(
    'global translation setting reveals text without per-ayah buttons',
    (tester) async {
      final preferences = _MemoryPreferencesRepository()
        ..value = const AppPreferences.defaults().copyWith(
          showTranslation: true,
          tapToShowTranslation: true,
        );
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(preferences: preferences),
          child: const MaterialApp(home: QuranReaderPage(surah: _surah)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fixture Bangla translation 1'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Show translation'), findsNothing);
      expect(find.widgetWithText(TextButton, 'Hide translation'), findsNothing);
    },
  );

  testWidgets(
    'reader is Surah-scoped continuous mode without page or global search controls',
    (tester) async {
      await tester.pumpWidget(_readerApp());
      await tester.pumpAndSettle();

      expect(find.text('surah001'), findsWidgets);
      expect(find.textContaining('আল-ফাতিহা'), findsWidgets);
      expect(find.byTooltip('Search Quran'), findsNothing);
      expect(find.textContaining('Page '), findsNothing);
      expect(find.byTooltip('Previous page'), findsNothing);
      expect(find.byTooltip('Next page'), findsNothing);
    },
  );

  testWidgets('long press keeps word details available', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(study: true),
        child: const MaterialApp(home: QuranReaderPage(surah: _surah)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('A'));
    await tester.pumpAndSettle();

    expect(find.text('Fixture meaning'), findsOneWidget);
    expect(find.text('বাংলা'), findsOneWidget);
  });

  testWidgets('reader word taps play, move, and clear the word highlight', (
    tester,
  ) async {
    final player = FakeAudioPlayerAdapter(autoComplete: false);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._overrides(),
          readerPlaybackRequestResolverProvider.overrideWithValue(
            _WordFixtureResolver(),
          ),
          audioPlayerAdapterProvider.overrideWithValue(player),
        ],
        child: const MaterialApp(home: QuranReaderPage(surah: _surah)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(tester.element(find.text('A')));
    expect(
      container.read(quranAudioControllerProvider).mode,
      QuranAudioMode.word,
    );
    expect(player.loadedSources, ['A.mp3']);
    expect(_wordColor(tester, 'A'), QuranReadingColors.activeWord);
    expect(_wordColor(tester, 'B'), isNot(QuranReadingColors.activeWord));

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(player.loadedSources, ['A.mp3', 'B.mp3']);
    expect(_wordColor(tester, 'A'), isNot(QuranReadingColors.activeWord));
    expect(_wordColor(tester, 'B'), QuranReadingColors.activeWord);

    player.completeCurrent();
    await tester.pumpAndSettle();
    expect(
      container.read(quranAudioControllerProvider).activeWordPosition,
      isNull,
    );
    expect(_wordColor(tester, 'A'), isNot(QuranReadingColors.activeWord));
    expect(_wordColor(tester, 'B'), isNot(QuranReadingColors.activeWord));
  });
}

Color? _wordColor(WidgetTester tester, String text) =>
    DefaultTextStyle.of(tester.element(find.text(text))).style.color;

class _WordFixtureResolver implements ReaderPlaybackRequestResolver {
  @override
  Future<WordPlaybackRequest> resolveWord(
    QuranAyah ayah,
    QuranWord word,
  ) async {
    return WordPlaybackRequest(
      source: '${word.arabic}.mp3',
      wordKey: '${ayah.key}:${word.position}',
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
  }) => throw UnimplementedError();
}

class _PlayingAyahController extends QuranAudioController {
  @override
  QuranAudioState build() => const QuranAudioState(
    mode: QuranAudioMode.ayah,
    status: QuranAudioStatus.playing,
    speed: 1,
    repeatIndex: 1,
    repeatTotal: 1,
    ayahKey: '1:1',
  );

  @override
  Future<void> stop() async => state = const QuranAudioState.initial();

  void nextFixtureAyah() => state = state.copyWith(ayahKey: '1:2');
}

class _FixtureBengaliMeanings implements BengaliWordMeanings {
  @override
  Future<bool> isSurahDownloaded(int surahNumber) async => false;

  @override
  Future<void> downloadSurah(
    int surahNumber,
    int ayahCount, {
    void Function(int completed, int total)? onProgress,
  }) async {}

  @override
  Future<String?> meaningFor(String ayahKey, int position) async =>
      ayahKey == '1:1' && position == 2 ? 'দ্বিতীয়' : null;
}

Widget _readerApp() => ProviderScope(
  overrides: _overrides(),
  child: const MaterialApp(home: QuranReaderPage(surah: _surah)),
);

_overrides({bool study = false, _MemoryPreferencesRepository? preferences}) => [
  quranRepositoryProvider.overrideWithValue(_ReaderFixtureRepository()),
  readingLocationStoreProvider.overrideWithValue(_NoopLocationStore()),
  appPreferencesRepositoryProvider.overrideWithValue(
    preferences ?? _MemoryPreferencesRepository(),
  ),
  if (study)
    studyControllerProvider.overrideWithValue(
      StudyController(_NoopStudyRepository()),
    ),
];

class _MemoryPreferencesRepository implements AppPreferencesRepository {
  AppPreferences value = const AppPreferences.defaults();

  @override
  Future<AppPreferences> load() async => value;

  @override
  Future<void> save(AppPreferences preferences) async {
    value = preferences;
  }
}

class _ReaderFixtureRepository implements QuranRepository {
  @override
  Future<List<QuranJuzSummary>> listJuzs() async => const [];

  @override
  Future<List<QuranSurahSummary>> listSurahs() async => const [_surah];

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
    if (page == 1) {
      return QuranPageWindow(
        page: 1,
        previousPage: null,
        nextPage: 2,
        ayahs: [
          QuranAyah(
            surahNumber: 1,
            ayahNumber: 1,
            arabicText: 'AB',
            pageNumber: 1,
            juzNumber: 1,
            translation: 'Fixture Bangla translation 1',
            words: [
              QuranWord(
                position: 1,
                arabic: 'A',
                banglaMeaning: 'Fixture meaning',
              ),
              QuranWord(position: 2, arabic: 'B'),
            ],
          ),
        ],
      );
    }
    if (page == 2) {
      return QuranPageWindow(
        page: 2,
        previousPage: 1,
        nextPage: 3,
        ayahs: [
          QuranAyah(
            surahNumber: 1,
            ayahNumber: 2,
            arabicText: 'C',
            pageNumber: 2,
            juzNumber: 1,
            translation: 'Fixture Bangla translation 2',
            words: [QuranWord(position: 1, arabic: 'C')],
          ),
          QuranAyah(
            surahNumber: 2,
            ayahNumber: 1,
            arabicText: 'D',
            pageNumber: 2,
            juzNumber: 1,
            translation: 'Adjacent Surah translation',
            words: [QuranWord(position: 1, arabic: 'D')],
          ),
        ],
      );
    }
    return QuranPageWindow(
      page: page,
      previousPage: page > 1 ? page - 1 : null,
      nextPage: page < 604 ? page + 1 : null,
      ayahs: const [],
    );
  }
}

class _NoopStudyRepository implements StudyRepository {
  @override
  Future<List<Bookmark>> listBookmarks({required String profileKey}) async =>
      const [];
  @override
  Future<Bookmark?> loadBookmark({
    required String profileKey,
    required StudyTarget target,
  }) async => null;
  @override
  Future<Note?> loadNote({
    required String profileKey,
    required StudyTarget target,
  }) async => null;
  @override
  Future<void> saveBookmark({
    required String profileKey,
    required StudyTarget target,
    required String category,
  }) async {}
  @override
  Future<void> deleteBookmark({
    required String profileKey,
    required StudyTarget target,
  }) async {}
  @override
  Future<void> saveNote({
    required String profileKey,
    required StudyTarget target,
    required String text,
  }) async {}
  @override
  Future<void> deleteNote({
    required String profileKey,
    required StudyTarget target,
  }) async {}
}

class _NoopLocationStore implements ReadingLocationStore {
  @override
  Future<ReadingLocation?> load() async => null;

  @override
  Future<void> save(ReadingLocation location) async {}
}
