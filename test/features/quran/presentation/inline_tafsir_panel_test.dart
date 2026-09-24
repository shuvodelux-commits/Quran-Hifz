import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/inline_tafsir_panel.dart';
import 'package:quran_hifz/features/tafsir/application/tafsir_providers.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_catalog.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_entry.dart';
import 'package:quran_hifz/features/tafsir/domain/tafsir_repository.dart';

void main() {
  testWidgets('inline tafsir lazily loads the primary Bangla tafsir', (
    tester,
  ) async {
    final repository = _FakeTafsirRepository(
      sources: const [
        TafsirSource(
          sourceId: primaryBanglaTafsirSourceId,
          name: primaryBanglaTafsirName,
          language: 'bn',
          version: '1',
        ),
      ],
      entry: const TafsirEntry(
        sourceId: primaryBanglaTafsirSourceId,
        sourceName: primaryBanglaTafsirName,
        language: 'bn',
        version: '1',
        surahNumber: 1,
        ayahNumber: 1,
        text: 'পরীক্ষামূলক তাফসীর',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [tafsirRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          home: Scaffold(
            body: InlineTafsirPanel(surahNumber: 1, ayahNumber: 1),
          ),
        ),
      ),
    );

    expect(repository.readCalls, 0);
    expect(find.text('পরীক্ষামূলক তাফসীর'), findsNothing);

    await tester.tap(find.text('Tafsir'));
    await tester.pumpAndSettle();

    expect(repository.readCalls, 1);
    expect(find.text(primaryBanglaTafsirName), findsOneWidget);
    expect(find.text('পরীক্ষামূলক তাফসীর'), findsOneWidget);
  });

  testWidgets(
    'inline tafsir stays independent from reader scroll PageStorage',
    (tester) async {
      final bucket = PageStorageBucket();
      final controller = ScrollController();
      final repository = _FakeTafsirRepository(sources: const []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [tafsirRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            home: PageStorage(
              bucket: bucket,
              child: Scaffold(
                body: SingleChildScrollView(
                  key: const PageStorageKey<String>('quran-continuous-reader'),
                  controller: controller,
                  child: const Column(
                    children: [
                      SizedBox(height: 400),
                      InlineTafsirPanel(surahNumber: 1, ayahNumber: 1),
                      SizedBox(height: 1200),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      controller.jumpTo(240);
      await tester.pump();

      expect(find.byType(ExpansionTile), findsNothing);
      expect(find.text('Tafsir'), findsOneWidget);

      await tester.tap(find.text('Tafsir'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Set up tafsir'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );

  testWidgets('inline tafsir shows setup action when no source is installed', (
    tester,
  ) async {
    final repository = _FakeTafsirRepository(sources: const []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [tafsirRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          home: Scaffold(
            body: InlineTafsirPanel(surahNumber: 1, ayahNumber: 1),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tafsir'));
    await tester.pumpAndSettle();

    expect(find.text('Set up tafsir'), findsOneWidget);
    expect(find.text(primaryBanglaTafsirName), findsOneWidget);
  });
}

class _FakeTafsirRepository implements TafsirRepository {
  @override
  Future<List<TafsirEntry>> readSurah({
    required String sourceId,
    required int surahNumber,
  }) async => entry == null ? [] : [entry!];
  _FakeTafsirRepository({required this.sources, this.entry});

  final List<TafsirSource> sources;
  final TafsirEntry? entry;
  int readCalls = 0;

  @override
  Future<List<TafsirSource>> listInstalledSources() async => sources;

  @override
  Future<TafsirEntry?> readAyah({
    required String sourceId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    readCalls++;
    return entry;
  }
}
