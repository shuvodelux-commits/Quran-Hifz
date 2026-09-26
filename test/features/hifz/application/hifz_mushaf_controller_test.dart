import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/application/hifz_mushaf_controller.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_mushaf_page.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_mushaf_page_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_reading_mode.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_font_repository.dart';

void main() {
  late _FakePageRepository pageRepo;
  late _FakeFontRepository fontRepo;
  late HifzMushafController controller;

  setUp(() {
    pageRepo = _FakePageRepository();
    fontRepo = _FakeFontRepository();
    final order = <String>[];
    pageRepo.sharedCallOrder = order;
    fontRepo.sharedCallOrder = order;
    controller = HifzMushafController(
      pageRepository: pageRepo,
      fontRepository: fontRepo,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  test('opening QPC page ensures its font then loads page data', () async {
    await controller.openPage(2);

    expect(fontRepo.ensuredPages, [2]);
    expect(pageRepo.loaded, [(HifzMushafVariant.qpcV4Tajweed, 2)]);
    expect(pageRepo.sharedCallOrder, ['font:2', 'page:qpcV4Tajweed:2']);
    expect(controller.state, isA<HifzMushafReady>());
    expect(controller.currentPage, 2);
  });

  test(
    'ready QPC page increments generation and prefetches neighbors',
    () async {
      await controller.openPage(2);
      final first = controller.state as HifzMushafReady;

      await controller.openPage(3);
      final second = controller.state as HifzMushafReady;

      expect(first.generation, 1);
      expect(second.generation, 2);
      expect(fontRepo.prefetchedPages, containsAll([2, 3]));
    },
  );

  test('Digital Khatt unavailable state does not call page loader', () async {
    pageRepo.digitalAvailable = false;

    await controller.selectVariant(HifzMushafVariant.digitalKhattV2);

    expect(controller.state, isA<HifzMushafUnavailable>());
    expect(pageRepo.loaded, isEmpty);
    expect(fontRepo.ensuredPages, isEmpty);
  });

  test(
    'Digital Khatt available page never downloads a QPC page font',
    () async {
      pageRepo.digitalAvailable = true;
      await controller.selectVariant(HifzMushafVariant.digitalKhattV2);

      await controller.openPage(1);

      expect(fontRepo.ensuredPages, isEmpty);
      expect(pageRepo.loaded, [(HifzMushafVariant.digitalKhattV2, 1)]);
      final ready = controller.state as HifzMushafReady;
      expect(ready.page.variant, HifzMushafVariant.digitalKhattV2);
    },
  );

  test('moves to active ayah page when auto-follow is enabled', () async {
    await controller.openPage(2);
    pageRepo.pagesByAyah['2:6'] = 3;

    await controller.followPlayback(
      ayahKey: '2:6',
      wordPosition: 1,
      autoFollow: true,
    );

    expect(controller.currentPage, 3);
  });

  test('does not force page change when auto-follow is disabled', () async {
    await controller.openPage(2);
    pageRepo.pagesByAyah['2:6'] = 3;
    final loadCount = pageRepo.loaded.length;

    await controller.followPlayback(
      ayahKey: '2:6',
      wordPosition: 1,
      autoFollow: false,
    );

    expect(controller.currentPage, 2);
    expect(pageRepo.loaded, hasLength(loadCount));
  });

  test('stale delayed page cannot restore an older playback page', () async {
    pageRepo.pagesByAyah['2:6'] = 3;
    pageRepo.pagesByAyah['2:17'] = 4;
    final page3 = Completer<void>();
    final page4 = Completer<void>();
    pageRepo.delayedPages[3] = page3;
    pageRepo.delayedPages[4] = page4;

    final first = controller.followPlayback(
      ayahKey: '2:6',
      wordPosition: 1,
      autoFollow: true,
    );
    await Future<void>.delayed(Duration.zero);
    final second = controller.followPlayback(
      ayahKey: '2:17',
      wordPosition: 1,
      autoFollow: true,
    );
    await Future<void>.delayed(Duration.zero);

    page4.complete();
    await Future<void>.delayed(Duration.zero);
    page3.complete();
    await Future.wait([first, second]);

    expect(controller.currentPage, 4);
    expect(controller.generation, greaterThan(0));
  });

  test('unsupported saved Digital palette is effective Light only', () async {
    controller.dispose();
    controller = HifzMushafController(
      pageRepository: pageRepo,
      fontRepository: fontRepo,
      initialVariant: HifzMushafVariant.digitalKhattV2,
      initialPalette: HifzMushafPalette.p6,
    );
    pageRepo.digitalAvailable = true;

    await controller.openPage(1);

    expect(controller.palette, HifzMushafPalette.p6);
    expect(
      (controller.state as HifzMushafReady).palette,
      HifzMushafPalette.light,
    );
  });
}

class _FakePageRepository implements HifzMushafPageRepository {
  bool digitalAvailable = false;
  final loaded = <(HifzMushafVariant, int)>[];
  final callOrder = <String>[];
  final pagesByAyah = <String, int>{};
  final delayedPages = <int, Completer<void>>{};
  List<String>? sharedCallOrder;

  @override
  Future<bool> isVariantAvailable(HifzMushafVariant variant) async {
    return variant == HifzMushafVariant.qpcV4Tajweed || digitalAvailable;
  }

  @override
  Future<HifzMushafPage> loadPage({
    required HifzMushafVariant variant,
    required int page,
  }) async {
    loaded.add((variant, page));
    (sharedCallOrder ?? callOrder).add('page:${variant.name}:$page');
    await delayedPages[page]?.future;
    return HifzMushafPage(
      page: page,
      variant: variant,
      lines: const <HifzMushafLine>[],
    );
  }

  @override
  Future<int?> pageForAyah({
    required HifzMushafVariant variant,
    required AyahRef ayah,
  }) async => pagesByAyah[ayah.verseKey];
}

class _FakeFontRepository implements QuranPageFontRepository {
  final ensuredPages = <int>[];
  final prefetchedPages = <int>[];
  final callOrder = <String>[];
  List<String>? sharedCallOrder;

  @override
  Future<Uri> ensurePageFont(int page) async {
    ensuredPages.add(page);
    (sharedCallOrder ?? callOrder).add('font:$page');
    return Uri.file('/tmp/qpc-v4/p$page.woff2');
  }

  @override
  Future<bool> isCached(int page) async => false;

  @override
  Future<void> prefetchNeighbors(int page) async {
    prefetchedPages.add(page);
  }
}
