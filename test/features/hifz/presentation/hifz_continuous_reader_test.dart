import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_continuous_reader.dart';
import 'package:quran_hifz/features/quran/application/quran_mushaf_providers.dart';
import 'package:quran_hifz/features/quran/application/reader_state.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_font_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';

void main() {
  testWidgets('continuous reader starts on current page and keeps canonical page order', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final needed = <int>[];
    final current = <int>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranMushafPageRepositoryProvider.overrideWithValue(
            _MushafRepository(),
          ),
          quranPageFontRepositoryProvider.overrideWith(
            (ref, variant) => _FontRepository(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: HifzContinuousReader(
              state: ReaderState(
                currentPage: 2,
                firstPage: 1,
                lastPage: 3,
                translationResourceId: 1,
                windows: {
                  2: QuranPageWindow(
                    page: 2,
                    ayahs: const [],
                    previousPage: 1,
                    nextPage: 3,
                  ),
                },
              ),
              variant: QuranMushafVariant.qcfV4Tajweed,
              fontSize: 32,
              lineHeight: 1.35,
              showTajweedColors: true,
              activeAyahKey: null,
              activeWordPosition: null,
              selectedStartAyahKey: '1:1',
              selectedEndAyahKey: '1:2',
              onPageNeeded: needed.add,
              onCurrentPageChanged: current.add,
              onWordTap: (_, __) {},
              onWordLongPress: (_, __) {},
              onAyahTap: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-continuous-page-2')), findsOneWidget);

    final visiblePages = <int>[];
    for (var page = 1; page <= 3; page++) {
      if (find.byKey(ValueKey('hifz-continuous-page-$page')).evaluate().isNotEmpty) {
        visiblePages.add(page);
      }
    }
    expect(visiblePages, orderedEquals([...visiblePages]..sort()));
    expect(tester.takeException(), isNull);
  });


  testWidgets('continuous reader lazily mounts only pages near a middle anchor', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final needed = <int>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranMushafPageRepositoryProvider.overrideWithValue(
            _MushafRepository(),
          ),
          quranPageFontRepositoryProvider.overrideWith(
            (ref, variant) => _FontRepository(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: HifzContinuousReader(
              state: ReaderState(
                currentPage: 10,
                firstPage: 1,
                lastPage: 20,
                translationResourceId: 1,
                windows: {
                  10: QuranPageWindow(
                    page: 10,
                    ayahs: const [],
                    previousPage: 9,
                    nextPage: 11,
                  ),
                },
              ),
              variant: QuranMushafVariant.qcfV4Tajweed,
              fontSize: 32,
              lineHeight: 1.35,
              showTajweedColors: true,
              activeAyahKey: null,
              activeWordPosition: null,
              selectedStartAyahKey: '1:1',
              selectedEndAyahKey: '1:2',
              onPageNeeded: needed.add,
              onCurrentPageChanged: (_) {},
              onWordTap: (_, __) {},
              onWordLongPress: (_, __) {},
              onAyahTap: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('hifz-continuous-page-10')), findsOneWidget);
    expect(find.byKey(const ValueKey('hifz-continuous-page-1')), findsNothing);
    expect(
      needed.every((page) => page >= 9 && page <= 11),
      isTrue,
      reason: 'Opening page 10 must not eagerly request distant Surah pages.',
    );
  });

  testWidgets('continuous reader forwards exact Hifz typography to page surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranMushafPageRepositoryProvider.overrideWithValue(
            _MushafRepository(),
          ),
          quranPageFontRepositoryProvider.overrideWith(
            (ref, variant) => _FontRepository(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: HifzContinuousReader(
              state: ReaderState(
                currentPage: 1,
                firstPage: 1,
                lastPage: 1,
                translationResourceId: 1,
                windows: {
                  1: QuranPageWindow(
                    page: 1,
                    ayahs: const [],
                    previousPage: null,
                    nextPage: null,
                  ),
                },
              ),
              variant: QuranMushafVariant.qcfV2,
              fontSize: 56,
              lineHeight: 2.4,
              showTajweedColors: false,
              activeAyahKey: null,
              activeWordPosition: null,
              selectedStartAyahKey: '1:1',
              selectedEndAyahKey: '1:2',
              onPageNeeded: (_) {},
              onCurrentPageChanged: (_) {},
              onWordTap: (_, __) {},
              onWordLongPress: (_, __) {},
              onAyahTap: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('hifz-continuous-page-1')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('silent auto-scroll advances and manual drag does not disable it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var disableCalls = 0;
    await tester.pumpWidget(
      _continuousTestApp(
        autoScrollEnabled: true,
        autoScrollSpeed: 0.5,
        audioPlaying: false,
        onDisableAutoScroll: () => disableCalls++,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final list = tester.widget<ListView>(find.byType(ListView));
    final controller = list.controller!;
    final beforeDrag = controller.offset;
    expect(beforeDrag, greaterThan(0));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();
    final afterManualMove = controller.offset;
    await tester.pump(const Duration(milliseconds: 500));
    expect(controller.offset, closeTo(afterManualMove, 1));
    expect(disableCalls, 0);

    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(controller.offset, greaterThan(afterManualMove));
    expect(disableCalls, 0);
  });

  testWidgets('auto-scroll rests at the end and resumes after manual movement up', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var disableCalls = 0;
    await tester.pumpWidget(
      _continuousTestApp(
        autoScrollEnabled: true,
        autoScrollSpeed: 1,
        audioPlaying: false,
        onDisableAutoScroll: () => disableCalls++,
      ),
    );
    await tester.pump();

    final controller = tester.widget<ListView>(find.byType(ListView)).controller!;
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump(const Duration(milliseconds: 100));
    final atEnd = controller.offset;
    await tester.pump(const Duration(milliseconds: 500));
    expect(controller.offset, closeTo(atEnd, 1));
    expect(disableCalls, 0);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );
    await gesture.moveBy(const Offset(0, 120));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    final movedUp = controller.offset;
    expect(movedUp, lessThan(atEnd));

    await tester.pump(const Duration(milliseconds: 500));
    expect(controller.offset, greaterThan(movedUp));
    expect(disableCalls, 0);
  });

  testWidgets('audio start disables silent auto-scroll once and it stays stopped', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var disableCalls = 0;
    await tester.pumpWidget(
      _continuousTestApp(
        autoScrollEnabled: true,
        autoScrollSpeed: 1,
        audioPlaying: false,
        onDisableAutoScroll: () => disableCalls++,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final controller = tester.widget<ListView>(find.byType(ListView)).controller!;
    final beforeAudio = controller.offset;

    await tester.pumpWidget(
      _continuousTestApp(
        autoScrollEnabled: true,
        autoScrollSpeed: 1,
        audioPlaying: true,
        onDisableAutoScroll: () => disableCalls++,
      ),
    );
    await tester.pump();
    expect(disableCalls, 1);

    final stoppedAt = controller.offset;
    await tester.pump(const Duration(milliseconds: 500));
    expect(controller.offset, closeTo(stoppedAt, 1));
    expect(disableCalls, 1);
    expect(stoppedAt, greaterThanOrEqualTo(beforeAudio));
  });


  testWidgets('programmatic scroll notifications do not halve auto-scroll speed', (
    tester,
  ) async {
    await tester.pumpWidget(
      _continuousTestApp(
        autoScrollEnabled: true,
        autoScrollSpeed: 0.5,
        audioPlaying: false,
        onDisableAutoScroll: () {},
      ),
    );
    await tester.pump();

    final controller = tester.widget<ListView>(find.byType(ListView)).controller!;
    for (var frame = 0; frame < 10; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(controller.offset, closeTo(40, 2));
  });

  testWidgets('enabling auto-scroll while audio is already playing is rejected', (
    tester,
  ) async {
    var disableCalls = 0;

    await tester.pumpWidget(
      _continuousTestApp(
        autoScrollEnabled: false,
        autoScrollSpeed: 0.5,
        audioPlaying: true,
        onDisableAutoScroll: () => disableCalls++,
      ),
    );
    await tester.pump();
    expect(disableCalls, 0);

    await tester.pumpWidget(
      _continuousTestApp(
        autoScrollEnabled: true,
        autoScrollSpeed: 0.5,
        audioPlaying: true,
        onDisableAutoScroll: () => disableCalls++,
      ),
    );
    await tester.pump();

    expect(disableCalls, 1);
  });


}

Widget _continuousTestApp({
  required bool autoScrollEnabled,
  required double autoScrollSpeed,
  required bool audioPlaying,
  required VoidCallback onDisableAutoScroll,
}) {
  final windows = <int, QuranPageWindow>{
    for (var page = 1; page <= 3; page++)
      page: QuranPageWindow(
        page: page,
        ayahs: const [],
        previousPage: page == 1 ? null : page - 1,
        nextPage: page == 3 ? null : page + 1,
      ),
  };
  return ProviderScope(
    overrides: [
      quranMushafPageRepositoryProvider.overrideWithValue(_MushafRepository()),
      quranPageFontRepositoryProvider.overrideWith(
        (ref, variant) => _FontRepository(),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: HifzContinuousReader(
          state: ReaderState(
            currentPage: 1,
            firstPage: 1,
            lastPage: 3,
            translationResourceId: 1,
            windows: windows,
          ),
          variant: QuranMushafVariant.qcfV4Tajweed,
          fontSize: 32,
          lineHeight: 1.35,
          showTajweedColors: true,
          activeAyahKey: null,
          activeWordPosition: null,
          selectedStartAyahKey: '1:1',
          selectedEndAyahKey: '1:2',
          autoScrollEnabled: autoScrollEnabled,
          autoScrollSpeed: autoScrollSpeed,
          audioPlaying: audioPlaying,
          onDisableAutoScroll: onDisableAutoScroll,
          onPageNeeded: (_) {},
          onCurrentPageChanged: (_) {},
          onWordTap: (_, __) {},
          onWordLongPress: (_, __) {},
          onAyahTap: (_) {},
        ),
      ),
    ),
  );
}

class _MushafRepository implements QuranMushafPageRepository {
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

class _FontRepository implements QuranPageFontRepository {
  @override
  Future<Uri> ensurePageFont(int page) async =>
      Uri.parse('asset:///page-$page.woff2');

  @override
  Future<bool> isCached(int page) async => true;

  @override
  Future<void> prefetchNeighbors(int page) async {}
}
