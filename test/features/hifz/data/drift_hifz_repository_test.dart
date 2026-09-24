import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/hifz/data/drift_hifz_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_preset.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_progress.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';

void main() {
  test('progress and resume checkpoint survive database reopen', () async {
    final temp = await Directory.systemTemp.createTemp('hifz-repository-test-');
    final file = File('${temp.path}/user_data.sqlite');

    final firstDb = UserDatabase.forTesting(NativeDatabase(file));
    final first = DriftHifzRepository(firstDb);
    final startedAt = DateTime.utc(2026, 9, 4, 12);
    const ayah = AyahRef(surahNumber: 67, ayahNumber: 1);
    const config = HifzSessionConfig(
      start: AyahRef(surahNumber: 67, ayahNumber: 1),
      end: AyahRef(surahNumber: 67, ayahNumber: 3),
      preset: HifzPresets.newMemorization,
    );

    await first.saveProgress(
      profileKey: 'default',
      progress: HifzProgress(
        ayah: ayah,
        status: HifzStatus.learning,
        strengthScore: 10,
        reviewCount: 0,
        mistakeCount: 0,
        startedAt: startedAt,
      ),
    );
    await first.saveCheckpoint(
      HifzSessionCheckpoint(
        profileKey: 'default',
        config: config,
        nextStepIndex: 2,
        status: HifzSessionStatus.stopped,
        updatedAt: startedAt,
      ),
    );
    await firstDb.close();

    final reopenedDb = UserDatabase.forTesting(NativeDatabase(file));
    addTearDown(() async {
      await reopenedDb.close();
      if (await temp.exists()) await temp.delete(recursive: true);
    });
    final reopened = DriftHifzRepository(reopenedDb);

    final progress = await reopened.loadProgress(
      profileKey: 'default',
      ayah: ayah,
    );
    final checkpoint = await reopened.loadCheckpoint('default');

    expect(progress?.status, HifzStatus.learning);
    expect(progress?.strengthScore, 10);
    expect(progress?.startedAt, startedAt);
    expect(checkpoint?.config.start, config.start);
    expect(checkpoint?.config.end, config.end);
    expect(checkpoint?.config.preset.id, HifzPresets.newMemorization.id);
    expect(checkpoint?.nextStepIndex, 2);
    expect(checkpoint?.status, HifzSessionStatus.stopped);
  });

  test('markRangeLearning preserves stronger existing status', () async {
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftHifzRepository(db);
    const ayah = AyahRef(surahNumber: 67, ayahNumber: 2);

    await repository.saveProgress(
      profileKey: 'default',
      progress: const HifzProgress(
        ayah: ayah,
        status: HifzStatus.strong,
        strengthScore: 90,
        reviewCount: 5,
        mistakeCount: 0,
      ),
    );

    await repository.markRangeLearning(
      profileKey: 'default',
      start: const AyahRef(surahNumber: 67, ayahNumber: 1),
      end: const AyahRef(surahNumber: 67, ayahNumber: 3),
    );

    final preserved = await repository.loadProgress(
      profileKey: 'default',
      ayah: ayah,
    );
    final newAyah = await repository.loadProgress(
      profileKey: 'default',
      ayah: const AyahRef(surahNumber: 67, ayahNumber: 1),
    );

    expect(preserved?.status, HifzStatus.strong);
    expect(preserved?.strengthScore, 90);
    expect(newAyah?.status, HifzStatus.learning);
  });
}
