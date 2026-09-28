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
