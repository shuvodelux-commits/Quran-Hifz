import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/quran_content_database.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/data/drift_quran_repository.dart';

void main() {
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
