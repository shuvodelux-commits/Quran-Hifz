import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/audio/application/audio_providers.dart';
import 'package:quran_hifz/features/audio/application/quran_audio_controller.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/reader_window.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';

void main() {
  testWidgets('reader follows the active word inside a long ayah', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final longAyah = QuranAyah(
      surahNumber: 1,
      ayahNumber: 1,
      pageNumber: 1,
      juzNumber: 1,
      words: [
        for (var position = 1; position <= 36; position++)
          QuranWord(position: position, arabic: 'كلمة$position'),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranAudioControllerProvider.overrideWith(
            _TestQuranAudioController.new,
          ),
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              scrollCacheExtent: const ScrollCacheExtent.pixels(1200),
              slivers: [
                ReaderWindow(
                  window: QuranPageWindow(
                    page: 1,
                    previousPage: null,
                    nextPage: null,
                    ayahs: [longAyah],
                  ),
                  showTranslation: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(ReaderWindow));
    final container = ProviderScope.containerOf(context);
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _TestQuranAudioController;

    controller.playAyahWord(ayahKey: '1:1', wordPosition: 34);
    await tester.pump();
    await tester.pumpAndSettle();

    final activeWord = find.text('كلمة34');
    expect(activeWord, findsOneWidget);
    final wordRect = tester.getRect(activeWord);
    final viewportRect = tester.getRect(find.byType(CustomScrollView));
    expect(wordRect.top, lessThan(viewportRect.bottom));
    expect(wordRect.bottom, greaterThan(viewportRect.top));
  });

  testWidgets('reader scrolls the active auto-next ayah into view', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranAudioControllerProvider.overrideWith(
            _TestQuranAudioController.new,
          ),
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryPreferencesRepository(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              scrollCacheExtent: const ScrollCacheExtent.pixels(900),
              slivers: [
                ReaderWindow(window: _fixtureWindow(), showTranslation: false),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(scrollable.position.pixels, 0);

    final context = tester.element(find.byType(ReaderWindow));
    final container = ProviderScope.containerOf(context);
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _TestQuranAudioController;

    controller.playAyahKey('1:4');
    await tester.pump();
    await tester.pumpAndSettle();

    expect(scrollable.position.pixels, greaterThan(0));
    final target = find.byKey(const ValueKey('ayah-1:4'));
    expect(target, findsOneWidget);
    final targetRect = tester.getRect(target);
    final viewportRect = tester.getRect(find.byType(CustomScrollView));
    expect(targetRect.top, lessThan(viewportRect.bottom));
    expect(targetRect.bottom, greaterThan(viewportRect.top));
  });
}

QuranPageWindow _fixtureWindow() {
  return QuranPageWindow(
    page: 1,
    previousPage: null,
    nextPage: 2,
    ayahs: [
      for (var ayah = 1; ayah <= 5; ayah++)
        QuranAyah(
          surahNumber: 1,
          ayahNumber: ayah,
          pageNumber: 1,
          juzNumber: 1,
          words: [QuranWord(position: 1, arabic: 'آية $ayah')],
        ),
    ],
  );
}

class _TestQuranAudioController extends QuranAudioController {
  @override
  QuranAudioState build() => const QuranAudioState.initial();

  void playAyahWord({required String ayahKey, required int wordPosition}) {
    state = QuranAudioState(
      mode: QuranAudioMode.ayah,
      status: QuranAudioStatus.playing,
      speed: 1,
      repeatIndex: 1,
      repeatTotal: 1,
      ayahKey: ayahKey,
      activeWordPosition: wordPosition,
    );
  }

  void playAyahKey(String ayahKey) {
    state = QuranAudioState(
      mode: QuranAudioMode.ayah,
      status: QuranAudioStatus.playing,
      speed: 1,
      repeatIndex: 1,
      repeatTotal: 1,
      ayahKey: ayahKey,
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
