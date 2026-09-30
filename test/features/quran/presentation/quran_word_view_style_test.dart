import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/audio/application/audio_providers.dart';
import 'package:quran_hifz/features/audio/application/quran_audio_controller.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';
import 'package:quran_hifz/features/quran/data/bengali_word_meanings.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';
import 'package:quran_hifz/features/quran/domain/quran_font_preference.dart';
import 'package:quran_hifz/features/quran/presentation/quran_reading_colors.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/quran_word_view.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/core/theme/app_palette.dart';
import 'package:quran_hifz/core/theme/reference_colors.dart';

void main() {
  for (final preference in AppThemePreference.values) {
    testWidgets(
      'active word highlight is a brighter matching ${preference.name} accent',
      (tester) async {
        final theme = appTheme(preference);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appPreferencesRepositoryProvider.overrideWithValue(
                _MemoryPreferencesRepository(),
              ),
            ],
            child: MaterialApp(
              theme: theme,
              home: const Scaffold(
                body: QuranWordView(
                  word: QuranWord(position: 1, arabic: 'اللَّه'),
                  isActive: true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final activeColor =
            DefaultTextStyle.of(
              tester.element(find.text('اللَّه')),
            ).style.color!;
        final baseColor = theme.colorScheme.primary;
        final activeHsv = HSVColor.fromColor(activeColor);
        final baseHsv = HSVColor.fromColor(baseColor);

        expect(activeColor, isNot(baseColor));
        expect((activeHsv.hue - baseHsv.hue).abs(), lessThan(1));
        expect(activeHsv.value, greaterThan(baseHsv.value));
        expect(
          activeHsv.value,
          greaterThanOrEqualTo(
            theme.brightness == Brightness.dark ? 0.84 : 0.70,
          ),
        );
        expect(activeHsv.saturation, inInclusiveRange(0.52, 0.78));
      },
    );
  }
  testWidgets(
    'graphite dark mode uses the blue-theme playback highlight',
    (tester) async {
      const graphite = Color(0xFF4C5054);
      final base = ThemeData.dark();
      final palette = AppPalette(
        readerAccent: graphite,
        accentPressed: graphite,
        accentTint: graphite,
        cardSurface: base.colorScheme.surfaceContainerLow,
        secondaryText: base.colorScheme.onSurfaceVariant,
        subtleBorder: base.colorScheme.outlineVariant,
        quranHeader: graphite,
        goldAccent: base.colorScheme.tertiary,
      );
      final theme = base.copyWith(extensions: [palette]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesRepositoryProvider.overrideWithValue(
              _MemoryPreferencesRepository(),
            ),
          ],
          child: MaterialApp(
            theme: theme,
            home: const Scaffold(
              body: QuranWordView(
                word: QuranWord(position: 1, arabic: 'اللَّه'),
                isActive: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final activeColor = DefaultTextStyle.of(
        tester.element(find.text('اللَّه')),
      ).style.color!;
      final activeHsv = HSVColor.fromColor(activeColor);
      final blueHsv = HSVColor.fromColor(ReferenceColors.appBlue);

      expect((activeHsv.hue - blueHsv.hue).abs(), lessThan(1));
      expect(activeHsv.saturation, greaterThanOrEqualTo(0.52));
      expect(activeHsv.value, greaterThanOrEqualTo(0.78));
    },
  );

  test(
    'Quran font manifest registers every exact family alias and asset',
    () async {
      const expectedAssetsByFamily = <String, List<String>>{
        'Inter': ['assets/fonts/Inter.ttf'],
        'SolaimanLipi': ['assets/fonts/SolaimanLipi.ttf'],
        'QPC Hafs': ['assets/fonts/UthmanicHafs1Ver18.ttf'],
        'IndoPak Nastaleeq': [
          'assets/fonts/indopak-nastaleeq-waqf-lazim-v4.2.1.ttf',
        ],
        'SurahNameV4': ['assets/fonts/surah-name-v4.ttf'],
        'QPC V4 Tajweed P1': ['assets/fonts/qpc-v4-tajweed-p1.ttf'],
      };
      final manifest =
          jsonDecode(await rootBundle.loadString('FontManifest.json'))
              as List<dynamic>;
      final assetsByFamily = <String, List<String>>{
        for (final entry in manifest)
          if (expectedAssetsByFamily.containsKey(entry['family']))
            entry['family'] as String: [
              for (final font in entry['fonts'] as List<dynamic>)
                font['asset'] as String,
            ],
      };

      expect(assetsByFamily, expectedAssetsByFamily);
      for (final asset in expectedAssetsByFamily.values.expand(
        (assets) => assets,
      )) {
        expect((await rootBundle.load(asset)).lengthInBytes, greaterThan(1000));
      }
    },
  );
  testWidgets('active playback changes only the current word text color', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: QuranWordView(
              word: QuranWord(position: 1, arabic: 'اللَّه'),
              isActive: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.text('اللَّه'));
    final effectiveStyle = DefaultTextStyle.of(context).style;
    expect(effectiveStyle.color, QuranReadingColors.activeWord);
    expect(
      find.ancestor(
        of: find.text('اللَّه'),
        matching: find.byType(AnimatedContainer),
      ),
      findsNothing,
    );
  });
  testWidgets('audio-active word uses the reference tap/playback blue', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
          quranAudioControllerProvider.overrideWith(
            _TestQuranAudioController.new,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: QuranWordView(
              word: QuranWord(position: 2, arabic: 'اللَّه'),
              playbackAyahKey: '1:1',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.text('اللَّه'));
    final container = ProviderScope.containerOf(context);
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _TestQuranAudioController;
    controller.setActiveWord(ayahKey: '1:1', wordPosition: 2);
    // QuranWordView deliberately animates the active-word color for 100 ms.
    // Wait for that transition to finish before asserting the final color.
    await tester.pumpAndSettle();

    final activeContext = tester.element(find.text('اللَّه'));
    expect(
      DefaultTextStyle.of(activeContext).style.color,
      QuranReadingColors.activeWord,
    );
  });

  testWidgets('direct word playback highlights the matching word', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
          quranAudioControllerProvider.overrideWith(
            _TestQuranAudioController.new,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: QuranWordView(
              word: QuranWord(position: 2, arabic: 'اللَّه'),
              playbackAyahKey: '1:1',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.text('اللَّه'));
    final controller =
        ProviderScope.containerOf(
              context,
            ).read(quranAudioControllerProvider.notifier)
            as _TestQuranAudioController;
    controller.setActiveWord(
      ayahKey: '1:1',
      wordPosition: 2,
      mode: QuranAudioMode.word,
    );
    await tester.pumpAndSettle();

    expect(
      DefaultTextStyle.of(tester.element(find.text('اللَّه'))).style.color,
      QuranReadingColors.activeWord,
    );
  });

  testWidgets('verified Tajweed markup renders colored spans when enabled', (
    tester,
  ) async {
    final preferences = _MemoryPreferencesRepository()
      ..value = const AppPreferences.defaults().copyWith(
        quranScript: QuranScriptPreference.uthmaniMadani,
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: QuranWordView(
              word: QuranWord(
                position: 1,
                arabic: 'ٱللَّهِ',
                arabicTajweedMarkup:
                    '<tajweed class=ham_wasl>ٱ</tajweed>للَّهِ',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final text = tester.widget<Text>(find.byType(Text).last);
    final textSpan = text.textSpan;
    expect(textSpan, isA<TextSpan>());
    expect((textSpan! as TextSpan).children, isNotEmpty);
  });

  testWidgets(
    'IndoPak uses its Quran font and script switching keeps word highlight',
    (tester) async {
      final preferences = _MemoryPreferencesRepository()
        ..value = const AppPreferences.defaults().copyWith(
          quranScript: QuranScriptPreference.indoPak,
        );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesRepositoryProvider.overrideWithValue(preferences),
            quranAudioControllerProvider.overrideWith(
              _TestQuranAudioController.new,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Text('Application label'),
                  QuranWordView(
                    word: QuranWord(
                      position: 2,
                      arabic: 'UTHMANI',
                      arabicIndopak: 'INDOPAK',
                    ),
                    playbackAyahKey: '1:1',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final indoPakContext = tester.element(find.text('INDOPAK'));
      final container = ProviderScope.containerOf(indoPakContext);
      final controller =
          container.read(quranAudioControllerProvider.notifier)
              as _TestQuranAudioController;
      controller.setActiveWord(
        ayahKey: '1:1',
        wordPosition: 2,
        mode: QuranAudioMode.word,
      );
      await tester.pumpAndSettle();

      final activeIndoPakContext = tester.element(find.text('INDOPAK'));
      final indoPakStyle = DefaultTextStyle.of(activeIndoPakContext).style;
      expect(indoPakStyle.fontFamily, 'IndoPak Nastaleeq');
      expect(indoPakStyle.color, QuranReadingColors.activeWord);
      expect(
        DefaultTextStyle.of(
          tester.element(find.text('Application label')),
        ).style.fontFamily,
        isNot('IndoPak Nastaleeq'),
      );

      await container
          .read(appPreferencesControllerProvider.notifier)
          .setQuranScript(QuranScriptPreference.uthmaniMadani);
      await tester.pumpAndSettle();
      final uthmaniStyle = DefaultTextStyle.of(
        tester.element(find.text('UTHMANI')),
      ).style;
      expect(uthmaniStyle.fontFamily, 'QPC Hafs');
      expect(uthmaniStyle.color, QuranReadingColors.activeWord);
    },
  );

  testWidgets('Quran word rendering uses the selected global Quran face', (
    tester,
  ) async {
    final preferences = _MemoryPreferencesRepository()
      ..value = const AppPreferences.defaults().copyWith(
        quranFont: QuranFontPreference.indoPak,
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: QuranWordView(word: QuranWord(position: 1, arabic: 'اللَّه')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final style = DefaultTextStyle.of(
      tester.element(find.text('اللَّه')),
    ).style;
    expect(style.fontFamily, 'IndoPak Nastaleeq');
  });

  testWidgets('bundled Bangla meaning never calls fallback service', (
    tester,
  ) async {
    final fallback = _CountingBengaliWordMeanings();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
          bengaliWordMeaningsProvider.overrideWithValue(fallback),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: QuranWordView(
              word: QuranWord(
                position: 1,
                arabic: 'اللَّه',
                banglaMeaning: 'আল্লাহ',
              ),
              playbackAyahKey: '1:1',
              onTap: _noop,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('اللَّه'));
    await tester.pump();

    expect(fallback.calls, 0);
  });

  testWidgets('long press does not trigger word tap audio callback', (
    tester,
  ) async {
    var taps = 0;
    var details = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: QuranWordView(
              word: const QuranWord(position: 1, arabic: 'اللَّه'),
              onTap: () => taps++,
              onLongPress: () => details++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('اللَّه'));
    await tester.pumpAndSettle();
    expect(details, 1);
    expect(taps, 0);
  });
}

void _noop() {}

class _CountingBengaliWordMeanings implements BengaliWordMeanings {
  int calls = 0;

  @override
  Future<String?> meaningFor(String ayahKey, int position) async {
    calls++;
    return 'fallback';
  }

  @override
  Future<bool> isSurahDownloaded(int surahNumber) async => false;

  @override
  Future<void> downloadSurah(
    int surahNumber,
    int ayahCount, {
    void Function(int completed, int total)? onProgress,
  }) async {}
}

class _TestQuranAudioController extends QuranAudioController {
  @override
  QuranAudioState build() => const QuranAudioState.initial();

  void setActiveWord({
    required String ayahKey,
    required int wordPosition,
    QuranAudioMode mode = QuranAudioMode.ayah,
  }) {
    state = QuranAudioState(
      mode: mode,
      status: QuranAudioStatus.playing,
      speed: 1,
      repeatIndex: 1,
      repeatTotal: 1,
      ayahKey: ayahKey,
      activeWordPosition: wordPosition,
    );
  }
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
