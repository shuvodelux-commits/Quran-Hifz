import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/hifz/data/drift_hifz_plan_repository.dart';
import 'package:quran_hifz/features/hifz/data/drift_hifz_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_preset.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_progress.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/quran/data/quran_translation_selection_store.dart';

void main() {
  test('Hifz writes preserve installed and selected translation sources', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await database
        .into(database.installedTranslationPackages)
        .insert(
          InstalledTranslationPackagesCompanion.insert(
            sourceId: 'qf.translation.20',
            resourceId: 20,
            name: 'Sahih International',
            language: 'english',
            version: 'quran-foundation-v4',
            localPath: '/tmp/sahih.sqlite',
            recordCount: 6236,
            installedAt: DateTime.utc(2026, 9, 27),
          ),
        );

    final selection = UserDatabaseQuranTranslationSelectionStore(database);
    await selection.write(const [
      'bundled.primary.bn',
      'qf.translation.20',
    ]);

    final plans = DriftHifzPlanRepository(database);
    final hifz = DriftHifzRepository(database);
    await plans.createPlan(
      profileKey: 'default',
      title: 'Al-Fatihah 1–2',
      start: const AyahRef(surahNumber: 1, ayahNumber: 1),
      end: const AyahRef(surahNumber: 1, ayahNumber: 2),
      startPage: 1,
      preset: HifzPresets.progressive(),
    );
    await hifz.saveProgress(
      profileKey: 'default',
      progress: const HifzProgress(
        ayah: AyahRef(surahNumber: 1, ayahNumber: 1),
        status: HifzStatus.learning,
        strengthScore: 0,
        reviewCount: 0,
        mistakeCount: 0,
      ),
    );
    await database.saveDailyGoal(
      profileKey: 'default',
      day: DateTime.utc(2026, 9, 27),
      newHifzAyahsTarget: 5,
      revisionAyahsTarget: 10,
      readingPagesTarget: 2,
    );

    final installed = await database.getInstalledTranslationPackage(
      'qf.translation.20',
    );
    expect(installed, isNotNull);
    expect(installed!.resourceId, 20);
    expect(installed.recordCount, 6236);
    expect(await selection.read(), [
      'bundled.primary.bn',
      'qf.translation.20',
    ]);
  });
}
