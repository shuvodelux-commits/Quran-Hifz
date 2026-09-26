import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/quran/data/quran_translation_selection_store.dart';
import 'package:quran_hifz/features/quran/domain/quran_translation_source.dart';

void main() {
  test('defaults to bundled Bangla translation', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final store = UserDatabaseQuranTranslationSelectionStore(database);

    expect(await store.read(), [bundledPrimaryTranslationSourceId]);
  });

  test('round trips multiple selected translation sources in order', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final store = UserDatabaseQuranTranslationSelectionStore(database);

    await store.write([
      bundledPrimaryTranslationSourceId,
      'qf.translation.20',
      'qf.translation.161',
    ]);

    expect(await store.read(), [
      bundledPrimaryTranslationSourceId,
      'qf.translation.20',
      'qf.translation.161',
    ]);
  });

  test('deduplicates and refuses an empty selection', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final store = UserDatabaseQuranTranslationSelectionStore(database);

    await store.write([
      'qf.translation.20',
      'qf.translation.20',
      bundledPrimaryTranslationSourceId,
    ]);
    expect(await store.read(), [
      'qf.translation.20',
      bundledPrimaryTranslationSourceId,
    ]);

    await expectLater(store.write(const []), throwsArgumentError);
  });
}
