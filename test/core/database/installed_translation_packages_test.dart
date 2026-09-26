import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';

void main() {
  test('installed translation package registry round trips and deletes', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await database.upsertInstalledTranslationPackage(
      sourceId: 'qf.translation.20',
      resourceId: 20,
      name: 'Sahih International',
      language: 'english',
      version: 'quran-foundation-v4',
      localPath: '/tmp/sahih.sqlite',
      author: 'Saheeh International',
      recordCount: 6236,
    );

    final record = await database.getInstalledTranslationPackage(
      'qf.translation.20',
    );
    expect(record, isNotNull);
    expect(record!.resourceId, 20);
    expect(record.name, 'Sahih International');
    expect(record.language, 'english');
    expect(record.recordCount, 6236);

    final all = await database.listInstalledTranslationPackages();
    expect(all.map((item) => item.sourceId), ['qf.translation.20']);

    await database.deleteInstalledTranslationPackage('qf.translation.20');
    expect(
      await database.getInstalledTranslationPackage('qf.translation.20'),
      isNull,
    );
  });
}
