import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/application/quran_mushaf_providers.dart';
import 'package:quran_hifz/features/quran/application/reader_state.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_window.dart';
import 'package:quran_hifz/features/quran/presentation/mushaf/quran_strict_reader_body.dart';

void main() {
  testWidgets('QCF V2 page load relies on repository availability check once', (
    tester,
  ) async {
    final repository = _CountingMushafRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranMushafPageRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          home: QuranStrictReaderBody(
            state: ReaderState(
              currentPage: 1,
              firstPage: 1,
              lastPage: 1,
              translationResourceId: 1,
              windows: {
                1: QuranPageWindow(
                  page: 1,
                  previousPage: null,
                  nextPage: 2,
                  ayahs: const [],
                ),
              },
            ),
            variant: QuranMushafVariant.qcfV2,
            fontSize: 32,
            lineHeight: 1.35,
            showTajweedColors: true,
            activeAyahKey: null,
            activeWordPosition: null,
            onPageChanged: (_) {},
            onWordTap: (_, __) {},
            onWordLongPress: (_, __) {},
            onAyahTap: (_) {},
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(repository.loadCalls, 1);
    expect(repository.availabilityCalls, 0);
  });
}

class _CountingMushafRepository implements QuranMushafPageRepository {
  final Completer<QcfMushafPage> _loadCompleter = Completer<QcfMushafPage>();
  int availabilityCalls = 0;
  int loadCalls = 0;

  @override
  Future<bool> isVariantAvailable(QuranMushafVariant variant) async {
    availabilityCalls++;
    return true;
  }

  @override
  Future<QcfMushafPage> loadPage({
    required QuranMushafVariant variant,
    required int page,
  }) {
    loadCalls++;
    return _loadCompleter.future;
  }
}
