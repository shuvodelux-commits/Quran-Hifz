import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/quran_content_database.dart';
import 'package:quran_hifz/features/quran/application/quran_mushaf_providers.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/data/drift_quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';

void main() {
  test('Mushaf startup selects assets only for the requested skin', () {
    expect(
      mushafAssetPathsForVariant(QuranMushafVariant.qcfV4Tajweed),
      (
        layout: 'assets/mushaf/layouts/qpc-v4-tajweed-15-lines.sqlite',
        script: 'assets/mushaf/scripts/qpc-v4-words.sqlite',
      ),
    );
    expect(
      mushafAssetPathsForVariant(QuranMushafVariant.qcfV2),
      (
        layout: 'assets/mushaf/layouts/qcf-v2-15-lines.sqlite',
        script: 'assets/mushaf/scripts/qcf-v2-words.sqlite',
      ),
    );
  });

  test('release repository composition is Drift-only', () {
    final database = QuranContentDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [quranContentDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    expect(
      container.read(quranRepositoryProvider),
      isA<DriftQuranRepository>(),
    );
  });
}
