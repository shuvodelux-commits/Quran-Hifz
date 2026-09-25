import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/tafsir/data/tafsir_source_selection_store.dart';

void main() {
  test('stores selected Tafsir source in app settings', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final store = UserDatabaseTafsirSourceSelectionStore(database);

    expect(await store.read(), isNull);

    await store.write('bn.other');

    expect(await store.read(), 'bn.other');
    expect(await database.getSetting('selected_tafsir_source_v1'), 'bn.other');
  });
}
