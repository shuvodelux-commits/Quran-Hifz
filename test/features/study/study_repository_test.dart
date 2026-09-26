import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/study/data/drift_study_repository.dart';
import 'package:quran_hifz/features/study/domain/bookmark.dart';

void main() {
  test('bookmark and note persist across user database reopen', () async {
    final temp = await Directory.systemTemp.createTemp('study-repository-');
    final file = File('${temp.path}/user_data.sqlite');
    const target = StudyTarget.word(
      surahNumber: 1,
      ayahNumber: 1,
      wordPosition: 2,
    );

    final firstDb = UserDatabase.forTesting(NativeDatabase(file));
    final first = DriftStudyRepository(firstDb);
    await first.saveBookmark(
      profileKey: 'default',
      target: target,
      category: 'General',
    );
    await first.saveNote(
      profileKey: 'default',
      target: target,
      text: 'Review this word carefully.',
    );
    await firstDb.close();

    final reopenedDb = UserDatabase.forTesting(NativeDatabase(file));
    addTearDown(() async {
      await reopenedDb.close();
      if (await temp.exists()) await temp.delete(recursive: true);
    });
    final reopened = DriftStudyRepository(reopenedDb);

    final bookmark = await reopened.loadBookmark(
      profileKey: 'default',
      target: target,
    );
    final note = await reopened.loadNote(profileKey: 'default', target: target);

    expect(bookmark?.category, 'General');
    expect(bookmark?.target, target);
    expect(note?.text, 'Review this word carefully.');
    expect(note?.target, target);
  });

  test(
    'delete removes only user study state for the selected target',
    () async {
      final db = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = DriftStudyRepository(db);
      const target = StudyTarget.ayah(surahNumber: 67, ayahNumber: 1);
      const other = StudyTarget.ayah(surahNumber: 67, ayahNumber: 2);

      await repository.saveBookmark(
        profileKey: 'default',
        target: target,
        category: 'General',
      );
      await repository.saveBookmark(
        profileKey: 'default',
        target: other,
        category: 'General',
      );
      await repository.saveNote(
        profileKey: 'default',
        target: target,
        text: 'target note',
      );
      await repository.saveNote(
        profileKey: 'default',
        target: other,
        text: 'other note',
      );

      await repository.deleteBookmark(profileKey: 'default', target: target);
      await repository.deleteNote(profileKey: 'default', target: target);

      expect(
        await repository.loadBookmark(profileKey: 'default', target: target),
        isNull,
      );
      expect(
        await repository.loadNote(profileKey: 'default', target: target),
        isNull,
      );
      expect(
        await repository.loadBookmark(profileKey: 'default', target: other),
        isNotNull,
      );
      expect(
        await repository.loadNote(profileKey: 'default', target: other),
        isNotNull,
      );
    },
  );

  test(
    'blank note text is rejected instead of storing meaningless rows',
    () async {
      final db = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = DriftStudyRepository(db);

      await expectLater(
        repository.saveNote(
          profileKey: 'default',
          target: const StudyTarget.ayah(surahNumber: 1, ayahNumber: 1),
          text: '   ',
        ),
        throwsArgumentError,
      );
    },
  );
}
