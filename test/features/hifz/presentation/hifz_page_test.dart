import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/audio/application/audio_providers.dart';
import 'package:quran_hifz/features/audio/application/quran_audio_controller.dart';
import 'package:quran_hifz/features/audio/domain/playback_requests.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_page.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_mushaf_page_view.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_mushaf_surface.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_system_ui.dart';
import 'package:quran_hifz/features/hifz/application/hifz_mushaf_providers.dart';
import 'package:quran_hifz/features/hifz/application/hifz_session_controller.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_audio_port.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_preset.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reading_mode.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_font_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_step.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/application/reader_audio_actions.dart';
import 'package:quran_hifz/features/quran/data/demo_quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_juz.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_line.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/domain/quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/quran/domain/quran_word.dart';
import 'package:quran_hifz/features/quran/presentation/quran_reading_colors.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/quran_word_view.dart';
import 'package:quran_hifz/features/reciters/application/reciter_catalog_controller.dart';
import 'package:quran_hifz/features/reciters/domain/chapter_reciter.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences_repository.dart';
import 'package:quran_hifz/features/study/presentation/word_details_sheet.dart';

import '../../../fakes/fake_audio_player_adapter.dart';

void main() {
  testWidgets('Regular mode keeps the existing continuous Hifz reader', (
    tester,
  ) async {
    final preferences = (const AppPreferences.defaults()).copyWith(
      hifzReadingMode: HifzReadingMode.regular,
      hifzLayoutMode: HifzLayoutMode.fixedMushaf,
    );

    await _pumpHifzPage(tester, preferences: preferences);

    expect(
      find.byKey(const PageStorageKey('hifz-continuous-reader')),
      findsOneWidget,
    );
    expect(find.byType(HifzMushafPageView), findsNothing);
  });

  testWidgets(
    'Mushaf mode is full screen and never shows fixed Hifz controls',
    (tester) async {
      final preferences = (const AppPreferences.defaults()).copyWith(
        hifzReadingMode: HifzReadingMode.mushaf,
      );

      await _pumpHifzPage(
        tester,
        preferences: preferences,
        mushafFontRepository: _FailingMushafFontRepository(),
      );

      expect(find.byType(HifzMushafPageView), findsOneWidget);
      expect(find.byKey(const ValueKey('hifz-top-controls')), findsNothing);
      expect(find.byKey(const ValueKey('hifz-bottom-controls')), findsNothing);
      expect(
        find.byKey(const ValueKey('hifz-reading-mode-selector')),
        findsNothing,
      );

      final pageRect = tester.getRect(find.byType(HifzMushafPageView));
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(pageRect.top, 0);
      expect(pageRect.bottom, screen.height);

      await tester.tapAt(pageRect.center);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('hifz-top-controls')), findsNothing);
      expect(find.byKey(const ValueKey('hifz-bottom-controls')), findsNothing);
    },
  );

  testWidgets('Mushaf mode exposes no fixed settings action', (tester) async {
    final preferences = (const AppPreferences.defaults()).copyWith(
      hifzReadingMode: HifzReadingMode.mushaf,
    );

    await _pumpHifzPage(
      tester,
      preferences: preferences,
      mushafFontRepository: _FailingMushafFontRepository(),
    );

    expect(find.byTooltip('Hifz settings'), findsNothing);
    expect(find.text('Mushaf appearance'), findsNothing);
  });

  testWidgets(
    'switching reading mode does not restart the active Hifz session',
    (tester) async {
      final preferences = (const AppPreferences.defaults()).copyWith(
        hifzReadingMode: HifzReadingMode.regular,
      );
      final audio = _HoldingHifzAudioPort();

      await _pumpHifzPage(
        tester,
        preferences: preferences,
        audioPort: audio,
        mushafFontRepository: _FailingMushafFontRepository(),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(HifzPage)),
      );
      const config = HifzSessionConfig(
        start: AyahRef(surahNumber: 1, ayahNumber: 1),
        end: AyahRef(surahNumber: 1, ayahNumber: 1),
        preset: HifzPresets.newMemorization,
      );

      final running = container
          .read(hifzSessionControllerProvider.notifier)
          .start(config);
      await tester.pump();
      while (audio.playCount == 0) {
        await tester.pump(const Duration(milliseconds: 10));
      }

      final before = container.read(hifzSessionControllerProvider);
      final playCount = audio.playCount;

      await container
          .read(appPreferencesControllerProvider.notifier)
          .setHifzReadingMode(HifzReadingMode.mushaf);
      await tester.pumpAndSettle();

      final inMushaf = container.read(hifzSessionControllerProvider);
      expect(identical(inMushaf.config, before.config), isTrue);
      expect(inMushaf.currentStepIndex, before.currentStepIndex);
      expect(inMushaf.stepRepeatIndex, before.stepRepeatIndex);
      expect(audio.playCount, playCount);

      await container
          .read(appPreferencesControllerProvider.notifier)
          .setHifzReadingMode(HifzReadingMode.regular);
      await tester.pumpAndSettle();

      final backInRegular = container.read(hifzSessionControllerProvider);
      expect(identical(backInRegular.config, before.config), isTrue);
      expect(backInRegular.currentStepIndex, before.currentStepIndex);
      expect(backInRegular.stepRepeatIndex, before.stepRepeatIndex);
      expect(audio.playCount, playCount);

      await container.read(hifzSessionControllerProvider.notifier).stop();
      await running;
    },
  );

  testWidgets('opens a saved plan at its range with setup ready', (
    tester,
  ) async {
    const config = HifzSessionConfig(
      start: AyahRef(surahNumber: 1, ayahNumber: 1),
      end: AyahRef(surahNumber: 1, ayahNumber: 2),
      preset: HifzPresets.newMemorization,
    );
    await _pumpHifzPage(tester, initialConfig: config, openSetupOnStart: true);

    expect(find.byKey(const ValueKey('hifz-setup-play')), findsOneWidget);
    expect(find.text('Ayah 1–2 · 2 ayahs · Al-Fatihah'), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-word-1:1:1')), findsOneWidget);
  });

  testWidgets('enters immersive Hifz and toggles clean controls by page tap', (
    tester,
  ) async {
    final systemUi = _RecordingHifzSystemUi();
    final player = FakeAudioPlayerAdapter(autoComplete: false);
    await _pumpHifzPage(tester, systemUi: systemUi, wordPlayer: player);

    expect(systemUi.enterCount, 1);
    expect(find.byKey(const ValueKey('hifz-top-controls')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-bottom-controls')), findsOneWidget);
    final firstSurface = find.byKey(const ValueKey('hifz-mushaf-1'));
    final top = tester.getRect(find.byKey(const ValueKey('hifz-top-controls')));
    final reading = tester.getRect(firstSurface);
    final bottom = tester.getRect(
      find.byKey(const ValueKey('hifz-bottom-controls')),
    );
    final firstWordBefore = tester.getRect(find.text('بِسْمِ'));
    expect(reading.top, greaterThanOrEqualTo(top.bottom));
    expect(reading.bottom, lessThanOrEqualTo(bottom.top));

    await tester.tap(find.text('بِسْمِ'));
    await tester.pumpAndSettle();
    expect(player.loadedSources, ['word-1.mp3']);
    expect(find.byKey(const ValueKey('hifz-top-controls')), findsOneWidget);

    final surfaceRect = tester.getRect(firstSurface);
    await tester.tapAt(Offset(surfaceRect.left + 2, surfaceRect.center.dy));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Visibility>(
            find.byKey(const ValueKey('hifz-top-controls-visibility')),
          )
          .visible,
      isFalse,
    );
    expect(
      tester
          .widget<Visibility>(
            find.byKey(const ValueKey('hifz-bottom-controls-visibility')),
          )
          .visible,
      isFalse,
    );
    expect(find.byKey(const ValueKey('hifz-clean-gesture')), findsNothing);
    expect(find.byType(QuranWordView), findsWidgets);
    expect(tester.getRect(firstSurface), reading);
    expect(tester.getRect(find.text('بِسْمِ')), firstWordBefore);

    await tester.tap(find.text('بِسْمِ'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Visibility>(
            find.byKey(const ValueKey('hifz-top-controls-visibility')),
          )
          .visible,
      isFalse,
    );

    await tester.tap(find.byKey(const ValueKey('hifz-reading-gesture')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('hifz-top-controls')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-bottom-controls')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(systemUi.restoreCount, 1);
  });

  testWidgets('Hifz opens as an uncluttered Quran reading page', (
    tester,
  ) async {
    await _pumpHifzPage(tester);

    expect(find.text('Hifz'), findsOneWidget);
    expect(find.byType(QuranWordView), findsWidgets);
    expect(find.byKey(const ValueKey('hifz-tools')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-active-player')), findsNothing);
    expect(find.text('Audio & Hifz'), findsNothing);
    expect(find.text('শুরুর আয়াত'), findsNothing);
    expect(find.text('শেষ আয়াত'), findsNothing);
    expect(find.byKey(const ValueKey('hifz-surah-selector')), findsOneWidget);
  });

  testWidgets('appearance controls update the open Hifz surface live', (
    tester,
  ) async {
    await _pumpHifzPage(tester);
    final word = find.byKey(const ValueKey('hifz-word-1:1:1'));
    final initialSize = _fontSize(tester, word)!;

    await tester.tap(find.byTooltip('Hifz settings'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('hifz-appearance-font-qpcHafs')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('IndoPak Nastaleeq').last);
    await tester.pumpAndSettle();
    expect(_fontFamily(tester, word), 'IndoPak Nastaleeq');

    final slider = find.byKey(const ValueKey('hifz-appearance-size'));
    final gesture = await tester.startGesture(tester.getCenter(slider));
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();
    expect(_fontSize(tester, word), greaterThan(initialSize));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('bottom Hifz expand chevron is centered with clear contrast', (
    tester,
  ) async {
    await _pumpHifzPage(tester);

    final toolsFinder = find.byKey(const ValueKey('hifz-tools'));
    final button = tester.widget<IconButton>(toolsFinder);
    final scheme = Theme.of(tester.element(toolsFinder)).colorScheme;
    expect(button.alignment, Alignment.center);
    expect(button.style?.backgroundColor?.resolve({}), scheme.primary);
    expect(button.style?.foregroundColor?.resolve({}), scheme.onPrimary);

    final iconFinder = find.descendant(
      of: toolsFinder,
      matching: find.byIcon(Icons.keyboard_arrow_up_rounded),
    );
    expect(find.byTooltip('Expand Audio & Hifz'), findsOneWidget);
    expect(
      tester.getCenter(iconFinder).dy,
      closeTo(tester.getCenter(toolsFinder).dy, .01),
    );
    expect(
      tester.getCenter(toolsFinder).dx,
      closeTo(
        tester.getCenter(find.byKey(const ValueKey('hifz-bottom-controls'))).dx,
        .01,
      ),
    );
  });

  testWidgets('vertical scrolling keeps loading Quran pages after page 1', (
    tester,
  ) async {
    final repository = _PagingRepository();
    await _pumpHifzPage(tester, repository: repository);

    expect(find.byKey(const ValueKey('hifz-mushaf-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-mushaf-2')), findsOneWidget);
    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, -600),
      1200,
    );
    await tester.pumpAndSettle();
    expect(repository.requestedPages, contains(2));
    expect(repository.requestedPages.every((page) => page >= 1), isTrue);
  });

  testWidgets('continuous reader never loads beyond Quran page 604', (
    tester,
  ) async {
    final repository = _PagingRepository();
    await _pumpHifzPage(tester, repository: repository, initialPage: 604);

    expect(find.byKey(const ValueKey('hifz-mushaf-604')), findsOneWidget);
    expect(repository.requestedPages.every((page) => page <= 604), isTrue);
  });

  testWidgets('flowing Hifz view only shows markers from the selected Surah', (
    tester,
  ) async {
    await _pumpHifzPage(tester, repository: _TwoSurahPageRepository());

    expect(find.byKey(const ValueKey('hifz-ayah-marker-1:1')), findsNothing);
    expect(find.byKey(const ValueKey('hifz-ayah-marker-1:2')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-ayah-marker-2:1')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('hifz-ayah-marker-1:2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hifz-tools')));
    await tester.pumpAndSettle();

    expect(find.text('Ayah 2–2 · 1 ayah · Al-Fatihah'), findsOneWidget);
  });

  testWidgets('Hifz word tap uses shared audio and long press opens details', (
    tester,
  ) async {
    final player = FakeAudioPlayerAdapter(autoComplete: false);
    await _pumpHifzPage(tester, wordPlayer: player);
    final first = find.text('بِسْمِ');
    final second = find.text('اللَّهِ');

    await tester.tap(first);
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(tester.element(first));
    expect(
      container.read(quranAudioControllerProvider).mode,
      QuranAudioMode.word,
    );
    expect(player.loadedSources, ['word-1.mp3']);
    expect(_wordColor(tester, first), QuranReadingColors.activeWord);
    expect(_wordColor(tester, second), isNot(QuranReadingColors.activeWord));

    await tester.tap(second);
    await tester.pumpAndSettle();
    expect(player.loadedSources, ['word-1.mp3', 'word-2.mp3']);
    expect(_wordColor(tester, first), isNot(QuranReadingColors.activeWord));
    expect(_wordColor(tester, second), QuranReadingColors.activeWord);

    await tester.longPress(first);
    await tester.pumpAndSettle();
    expect(find.byType(WordDetailsSheet), findsOneWidget);
    expect(player.loadedSources, ['word-1.mp3', 'word-2.mp3']);
  });

  testWidgets('completed ayah audio does not leave Hifz reading focus', (
    tester,
  ) async {
    await _pumpHifzPage(tester, completedAyahAudio: true);

    expect(find.byKey(const ValueKey('hifz-active-player')), findsNothing);
    expect(find.byKey(const ValueKey('hifz-ayah-1:1')), findsNothing);
    expect(
      _wordColor(tester, find.byKey(const ValueKey('hifz-word-1:1:1'))),
      isNot(QuranReadingColors.activeWord),
    );
  });

  testWidgets('Hifz tools open and close an Audio & Hifz setup sheet', (
    tester,
  ) async {
    await _pumpHifzPage(tester);

    await tester.tap(find.byKey(const ValueKey('hifz-tools')));
    await tester.pumpAndSettle();

    expect(find.text('Audio & Hifz'), findsOneWidget);
    expect(find.text('Start Range'), findsOneWidget);
    expect(find.text('End Range'), findsOneWidget);
    expect(find.text('Pattern'), findsOneWidget);
    expect(find.text('Advanced Settings'), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-setup-play')), findsOneWidget);
    expect(find.byType(QuranWordView), findsWidgets);

    final collapse = find.byTooltip('Collapse Audio & Hifz');
    expect(
      find.descendant(
        of: collapse,
        matching: find.byIcon(Icons.keyboard_arrow_down_rounded),
      ),
      findsOneWidget,
    );
    await tester.tap(collapse);
    await tester.pumpAndSettle();
    expect(find.text('Audio & Hifz'), findsNothing);
    expect(find.byKey(const ValueKey('hifz-tools')), findsOneWidget);
  });

  testWidgets('range pickers preserve a valid selected ayah interval', (
    tester,
  ) async {
    await _pumpHifzPage(tester);
    await tester.tap(find.byKey(const ValueKey('hifz-tools')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('hifz-start-range')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hifz-ayah-choice-1')));
    await tester.pumpAndSettle();
    expect(find.text('Ayah 1–1 · 1 ayah · Al-Fatihah'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('hifz-end-range')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hifz-ayah-choice-2')));
    await tester.pumpAndSettle();
    expect(find.text('Ayah 1–2 · 2 ayahs · Al-Fatihah'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('hifz-start-range')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hifz-ayah-choice-2')));
    await tester.pumpAndSettle();
    expect(find.text('Ayah 2–2 · 1 ayah · Al-Fatihah'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('hifz-end-range')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('hifz-ayah-choice-1')), findsNothing);
    expect(find.byKey(const ValueKey('hifz-ayah-choice-2')), findsOneWidget);
  });

  testWidgets('choosing a pattern updates setup without starting playback', (
    tester,
  ) async {
    await _pumpHifzPage(tester);
    await tester.tap(find.byKey(const ValueKey('hifz-tools')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hifz-pattern')));
    await tester.pumpAndSettle();

    expect(find.text('Pattern'), findsWidgets);
    expect(find.byKey(const ValueKey('hifz-sequence-preview')), findsOneWidget);
    await tester.tap(find.text('4×').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hifz-pattern-save')));
    await tester.pumpAndSettle();

    expect(find.text('Audio & Hifz'), findsOneWidget);
    expect(find.text('Each ×4 · cumulative ×3 · final ×3'), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HifzPage)),
    );
    expect(
      container.read(hifzSessionControllerProvider).status,
      HifzSessionStatus.idle,
    );
  });

  testWidgets(
    'Play enters focus, pause remains coherent, and stop restores reading',
    (tester) async {
      final port = _HoldingHifzAudioPort();
      await _pumpHifzPage(tester, audioPort: port, selectedReciter: true);
      await tester.tap(find.byKey(const ValueKey('hifz-tools')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('hifz-setup-play')))
            .onPressed,
        isNull,
      );

      await tester.tap(find.byKey(const ValueKey('hifz-start-range')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('hifz-ayah-choice-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('hifz-end-range')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('hifz-ayah-choice-2')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('hifz-setup-play')));
      await tester.pumpAndSettle();

      expect(find.text('Audio & Hifz'), findsNothing);
      expect(find.byKey(const ValueKey('hifz-tools')), findsNothing);
      expect(find.byKey(const ValueKey('hifz-surah-selector')), findsNothing);
      expect(find.byKey(const ValueKey('hifz-active-player')), findsOneWidget);
      expect(find.byType(QuranWordView), findsWidgets);
      expect(find.textContaining('Ayah 1–2'), findsWidgets);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(HifzPage)),
      );
      final running = container.read(hifzSessionControllerProvider);
      expect(running.status, HifzSessionStatus.running);
      expect(running.config?.preset.ayahRepeatCount, 5);
      expect(running.config?.preset.combinedRepeatCount, 3);

      await tester.tap(find.byTooltip('Hifz settings'));
      await tester.pumpAndSettle();
      expect(find.text('Hifz settings'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('hifz-appearance-preview')),
        findsOneWidget,
      );
      expect(find.text('সেটিংস'), findsNothing);
      Navigator.of(tester.element(find.text('Hifz settings'))).pop();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('hifz-active-player')), findsOneWidget);
      expect(
        container.read(hifzSessionControllerProvider).status,
        HifzSessionStatus.running,
      );

      await tester.tap(find.byTooltip('Pause Hifz'));
      await tester.pumpAndSettle();
      expect(port.pauseCount, 1);
      expect(
        container.read(hifzSessionControllerProvider).status,
        HifzSessionStatus.paused,
      );
      expect(find.byTooltip('Resume Hifz'), findsOneWidget);

      await tester.tap(find.byTooltip('Resume Hifz'));
      await tester.pumpAndSettle();
      expect(port.resumeCount, 1);

      await tester.tap(find.byTooltip('Stop Hifz'));
      await tester.pumpAndSettle();
      expect(port.stopCount, 1);
      expect(
        container.read(hifzSessionControllerProvider).status,
        HifzSessionStatus.stopped,
      );
      expect(find.byKey(const ValueKey('hifz-active-player')), findsNothing);
      expect(find.byKey(const ValueKey('hifz-tools')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('hifz-tools')));
      await tester.pumpAndSettle();
      expect(find.text('Ayah 1–2 · 2 ayahs · Al-Fatihah'), findsOneWidget);
      expect(find.byKey(const ValueKey('hifz-resume-saved')), findsOneWidget);
    },
  );

  testWidgets(
    'regular typography changes do not affect Hifz focus or playback',
    (tester) async {
      final port = _HoldingHifzAudioPort();
      await _pumpHifzPage(
        tester,
        audioPort: port,
        selectedReciter: true,
        useScriptOverride: false,
      );
      await tester.tap(find.byKey(const ValueKey('hifz-tools')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('hifz-start-range')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('hifz-ayah-choice-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('hifz-setup-play')));
      await tester.pumpAndSettle();

      final word = find.byKey(const ValueKey('hifz-word-1:2:1'));
      expect(_fontFamily(tester, word), 'QPC Hafs');
      expect(_fontSize(tester, word), 32);
      final container = ProviderScope.containerOf(tester.element(word));
      await container
          .read(appPreferencesControllerProvider.notifier)
          .setQuranScript(QuranScriptPreference.uthmaniMadani);
      await container
          .read(appPreferencesControllerProvider.notifier)
          .setArabicFontSize(42);
      await container
          .read(appPreferencesControllerProvider.notifier)
          .setDefaultPlaybackSpeed(1.25);
      await tester.pumpAndSettle();

      expect(_fontFamily(tester, word), 'QPC Hafs');
      expect(_fontSize(tester, word), 32);
      expect(container.read(defaultPlaybackSpeedProvider), 1.25);
      expect(port.playCount, 1);
      expect(port.stopCount, 0);
      expect(
        container.read(hifzSessionControllerProvider).status,
        HifzSessionStatus.running,
      );
    },
  );

  for (final size in <Size>[
    const Size(360, 800),
    const Size(390, 844),
    const Size(412, 915),
    const Size(1024, 768),
  ]) {
    testWidgets('reading, sheet, and player fit ${size.width}×${size.height}', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final port = _HoldingHifzAudioPort();
      await _pumpHifzPage(tester, audioPort: port, selectedReciter: true);

      expect(find.byType(HifzMushafSurface), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('hifz-tools')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('hifz-setup-play')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('hifz-pattern'))).height,
        lessThan(56),
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey('hifz-start-range')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('hifz-ayah-choice-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('hifz-setup-play')));
      await tester.pumpAndSettle();

      final player = find.byKey(const ValueKey('hifz-active-player'));
      expect(player, findsOneWidget);
      expect(find.byType(QuranWordView), findsWidgets);
      expect(
        tester.getRect(find.byType(HifzMushafSurface).first).height,
        greaterThan(size.height * 0.3),
      );
      expect(tester.getRect(player).bottom, lessThanOrEqualTo(size.height));
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Stop Hifz'));
      await tester.pumpAndSettle();
    });
  }
}

Future<void> _pumpHifzPage(
  WidgetTester tester, {
  HifzAudioPort? audioPort,
  bool selectedReciter = false,
  FakeAudioPlayerAdapter? wordPlayer,
  bool completedAyahAudio = false,
  bool useScriptOverride = true,
  QuranRepository? repository,
  HifzSystemUi? systemUi,
  int initialPage = 1,
  HifzSessionConfig? initialConfig,
  bool openSetupOnStart = false,
  AppPreferences? preferences,
  QuranPageFontRepository? mushafFontRepository,
}) async {
  final database = UserDatabase.forTesting(NativeDatabase.memory());
  addTearDown(database.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userDatabaseProvider.overrideWithValue(database),
        quranRepositoryProvider.overrideWithValue(
          repository ?? DemoQuranRepository(),
        ),
        if (useScriptOverride)
          quranScriptPreferenceProvider.overrideWithValue(
            QuranScriptPreference.indoPak,
          ),
        if (audioPort != null)
          hifzAudioPortProvider.overrideWithValue(audioPort),
        if (selectedReciter)
          reciterCatalogControllerProvider.overrideWith(
            _SelectedReciterCatalogController.new,
          ),
        if (wordPlayer != null) ...[
          readerPlaybackRequestResolverProvider.overrideWithValue(
            _WordFixtureResolver(),
          ),
          audioPlayerAdapterProvider.overrideWithValue(wordPlayer),
        ],
        if (completedAyahAudio)
          quranAudioControllerProvider.overrideWith(
            _CompletedAyahAudioController.new,
          ),
        if (systemUi != null) hifzSystemUiProvider.overrideWithValue(systemUi),
        if (preferences != null)
          appPreferencesRepositoryProvider.overrideWithValue(
            _MemoryAppPreferencesRepository(preferences),
          ),
        if (mushafFontRepository != null)
          hifzMushafPageFontRepositoryProvider.overrideWithValue(
            mushafFontRepository,
          ),
      ],
      child: MaterialApp(
        home: HifzPage(
          key: ValueKey('hifz-page-$initialPage'),
          initialPage: initialPage,
          initialConfig: initialConfig,
          openSetupOnStart: openSetupOnStart,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _RecordingHifzSystemUi implements HifzSystemUi {
  int enterCount = 0;
  int restoreCount = 0;

  @override
  Future<void> enter() async => enterCount++;

  @override
  Future<void> restore() async => restoreCount++;
}

class _PagingRepository implements QuranRepository {
  final requestedPages = <int>[];

  static const _surah = QuranSurahSummary(
    number: 1,
    nameArabic: 'الفاتحة',
    nameEnglish: 'Al-Fatihah',
    ayahCount: 7,
    pageStart: 1,
    pageEnd: 604,
    juzStart: 1,
  );

  @override
  Future<List<QuranSurahSummary>> listSurahs() async => const [_surah];

  @override
  Future<List<QuranJuzSummary>> listJuzs() async => const [];

  @override
  Future<QuranAyah?> loadAyah({
    required int surahNumber,
    required int ayahNumber,
    required int translationResourceId,
  }) async => QuranAyah(
    surahNumber: 1,
    ayahNumber: ayahNumber,
    pageNumber: ayahNumber,
    words: const [QuranWord(position: 1, arabic: 'آية')],
  );

  @override
  Future<QuranPageWindow> loadPageWindow({
    required int page,
    required int translationResourceId,
  }) async {
    requestedPages.add(page);
    return QuranPageWindow(
      page: page,
      previousPage: page > 1 ? page - 1 : null,
      nextPage: page < 604 ? page + 1 : null,
      ayahs: [
        QuranAyah(
          surahNumber: 1,
          ayahNumber: page == 604 ? 7 : (page % 7) + 1,
          pageNumber: page,
          words: const [QuranWord(position: 1, arabic: 'آية')],
        ),
      ],
    );
  }
}

class _TwoSurahPageRepository implements QuranRepository {
  static const _surahs = [
    QuranSurahSummary(
      number: 1,
      nameArabic: 'الفاتحة',
      nameEnglish: 'Al-Fatihah',
      ayahCount: 7,
      pageStart: 1,
      pageEnd: 1,
      juzStart: 1,
    ),
    QuranSurahSummary(
      number: 2,
      nameArabic: 'البقرة',
      nameEnglish: 'Al-Baqarah',
      ayahCount: 286,
      pageStart: 1,
      pageEnd: 49,
      juzStart: 1,
    ),
  ];
  static const _ayahs = [
    QuranAyah(
      surahNumber: 1,
      ayahNumber: 1,
      pageNumber: 1,
      words: [QuranWord(position: 1, arabic: 'بِسْمِ')],
    ),
    QuranAyah(
      surahNumber: 1,
      ayahNumber: 2,
      pageNumber: 1,
      words: [QuranWord(position: 1, arabic: 'الْحَمْدُ')],
    ),
    QuranAyah(
      surahNumber: 2,
      ayahNumber: 1,
      pageNumber: 1,
      words: [QuranWord(position: 1, arabic: 'الٓمّٓ')],
    ),
  ];

  @override
  Future<List<QuranSurahSummary>> listSurahs() async => _surahs;

  @override
  Future<List<QuranJuzSummary>> listJuzs() async => const [];

  @override
  Future<QuranAyah?> loadAyah({
    required int surahNumber,
    required int ayahNumber,
    required int translationResourceId,
  }) async => _ayahs
      .where(
        (ayah) =>
            ayah.surahNumber == surahNumber && ayah.ayahNumber == ayahNumber,
      )
      .firstOrNull;

  @override
  Future<QuranPageWindow> loadPageWindow({
    required int page,
    required int translationResourceId,
  }) async => QuranPageWindow(
    page: page,
    previousPage: null,
    nextPage: page == 1 ? 2 : null,
    ayahs: page == 1 ? _ayahs : const [],
    lines: page == 1
        ? [
            QuranMushafLine(
              lineNumber: 1,
              type: QuranMushafLineType.ayah,
              centered: false,
              surahNumber: 1,
              wordLocations: const [
                QuranWordLocation(surahNumber: 1, ayahNumber: 1, position: 1),
              ],
            ),
            QuranMushafLine(
              lineNumber: 2,
              type: QuranMushafLineType.ayah,
              centered: false,
              surahNumber: 2,
              wordLocations: const [
                QuranWordLocation(surahNumber: 2, ayahNumber: 1, position: 1),
              ],
            ),
          ]
        : const [],
  );
}

class _CompletedAyahAudioController extends QuranAudioController {
  @override
  QuranAudioState build() => const QuranAudioState(
    mode: QuranAudioMode.ayah,
    status: QuranAudioStatus.completed,
    speed: 1,
    repeatIndex: 1,
    repeatTotal: 1,
    ayahKey: '1:1',
  );
}

Color? _wordColor(WidgetTester tester, Finder word) =>
    DefaultTextStyle.of(tester.element(word)).style.color;

String? _fontFamily(WidgetTester tester, Finder word) => tester
    .widget<AnimatedDefaultTextStyle>(
      find.descendant(
        of: word,
        matching: find.byType(AnimatedDefaultTextStyle),
      ),
    )
    .style
    .fontFamily;

double? _fontSize(WidgetTester tester, Finder word) => tester
    .widget<AnimatedDefaultTextStyle>(
      find.descendant(
        of: word,
        matching: find.byType(AnimatedDefaultTextStyle),
      ),
    )
    .style
    .fontSize;

class _WordFixtureResolver implements ReaderPlaybackRequestResolver {
  @override
  Future<WordPlaybackRequest> resolveWord(
    QuranAyah ayah,
    QuranWord word,
  ) async => WordPlaybackRequest(
    source: 'word-${word.position}.mp3',
    wordKey: '${ayah.key}:${word.position}',
    ayahKey: ayah.key,
    wordPosition: word.position,
  );

  @override
  Future<AyahPlaybackRequest> resolveAyah(
    QuranAyah ayah, {
    required int repeatCount,
    required Duration pauseBetweenRepeats,
    required double speed,
  }) => throw UnimplementedError();
}

class _SelectedReciterCatalogController extends ReciterCatalogController {
  @override
  Future<ReciterCatalogState> build() async => const ReciterCatalogState(
    reciters: [
      ChapterReciter(
        id: 7,
        name: 'Test reciter',
        styleName: null,
        styleLanguageName: null,
        qiratName: null,
        qiratLanguageName: null,
      ),
    ],
    selectedReciterId: 7,
  );
}

class _HoldingHifzAudioPort implements HifzAudioPort {
  final Completer<void> _playback = Completer<void>();
  int playCount = 0;
  int pauseCount = 0;
  int resumeCount = 0;
  int stopCount = 0;

  @override
  Future<void> playStep(HifzStep step, {HifzStepProgressCallback? onProgress}) {
    playCount++;
    return _playback.future;
  }

  @override
  Future<void> pause() async => pauseCount++;

  @override
  Future<void> resume() async => resumeCount++;

  @override
  Future<void> stop() async {
    stopCount++;
    if (!_playback.isCompleted) {
      _playback.completeError(const HifzPlaybackStoppedException());
    }
  }
}

class _MemoryAppPreferencesRepository implements AppPreferencesRepository {
  _MemoryAppPreferencesRepository(this.value);

  AppPreferences value;

  @override
  Future<AppPreferences> load() async => value;

  @override
  Future<void> save(AppPreferences preferences) async {
    value = preferences;
  }
}

class _FailingMushafFontRepository implements QuranPageFontRepository {
  @override
  Future<Uri> ensurePageFont(int page) async {
    throw StateError('Mushaf font intentionally unavailable in widget test.');
  }

  @override
  Future<bool> isCached(int page) async => false;

  @override
  Future<void> prefetchNeighbors(int page) async {}
}
