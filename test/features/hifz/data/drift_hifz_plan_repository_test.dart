import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/hifz/data/drift_hifz_plan_repository.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_preset.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';

void main() {
  test('stores any number of plans and streams newest first', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftHifzPlanRepository(database);

    for (var index = 1; index <= 12; index++) {
      await repository.createPlan(
        profileKey: 'default',
        title: 'Plan $index',
        start: AyahRef(surahNumber: 2, ayahNumber: index),
        end: AyahRef(surahNumber: 2, ayahNumber: index + 1),
        startPage: 2,
        preset: HifzPresets.progressive(
          ayahRepeatCount: 5,
          combinedRepeatCount: 3,
          finalRangeRepeatCount: 3,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    final plans = await repository.watchPlans('default').first;
    expect(plans, hasLength(12));
    expect(plans.first.title, 'Plan 12');
    expect(plans.last.title, 'Plan 1');
    expect(plans.first.start.verseKey, '2:12');
    expect(plans.first.end.verseKey, '2:13');
    expect(plans.first.startPage, 2);
    expect(plans.first.preset.ayahRepeatCount, 5);
  });

  test('updates the saved repeat pattern for an existing plan', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftHifzPlanRepository(database);

    final id = await repository.createPlan(
      profileKey: 'default',
      title: 'Editable',
      start: const AyahRef(surahNumber: 1, ayahNumber: 1),
      end: const AyahRef(surahNumber: 1, ayahNumber: 5),
      startPage: 1,
      preset: HifzPresets.progressive(),
    );

    final updated = HifzPresets.progressive(
      ayahRepeatCount: 3,
      combinedRepeatCount: 2,
      finalRangeRepeatCount: 1,
      pauseBetweenRepeats: const Duration(milliseconds: 500),
    );
    await repository.updatePreset(id, updated);

    final plans = await repository.watchPlans('default').first;
    expect(plans.single.preset.id, updated.id);
    expect(plans.single.preset.ayahRepeatCount, 3);
    expect(plans.single.preset.combinedRepeatCount, 2);
    expect(plans.single.preset.finalRangeRepeatCount, 1);
    expect(
      plans.single.preset.pauseBetweenRepeats,
      const Duration(milliseconds: 500),
    );
  });

  test('deletes only the selected plan', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftHifzPlanRepository(database);

    final firstId = await repository.createPlan(
      profileKey: 'default',
      title: 'First',
      start: const AyahRef(surahNumber: 1, ayahNumber: 1),
      end: const AyahRef(surahNumber: 1, ayahNumber: 2),
      startPage: 1,
      preset: HifzPresets.newMemorization,
    );
    await repository.createPlan(
      profileKey: 'default',
      title: 'Second',
      start: const AyahRef(surahNumber: 2, ayahNumber: 1),
      end: const AyahRef(surahNumber: 2, ayahNumber: 3),
      startPage: 2,
      preset: HifzPresets.newMemorization,
    );

    await repository.deletePlan(firstId);

    final plans = await repository.watchPlans('default').first;
    expect(plans.map((plan) => plan.title), ['Second']);
  });
  test('rejects invalid cross-Surah and reversed ranges', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftHifzPlanRepository(database);

    expect(
      () => repository.createPlan(
        profileKey: 'default',
        title: 'Invalid',
        start: const AyahRef(surahNumber: 1, ayahNumber: 1),
        end: const AyahRef(surahNumber: 2, ayahNumber: 1),
        startPage: 1,
        preset: HifzPresets.newMemorization,
      ),
      throwsArgumentError,
    );
    expect(
      () => repository.createPlan(
        profileKey: 'default',
        title: 'Reversed',
        start: const AyahRef(surahNumber: 2, ayahNumber: 5),
        end: const AyahRef(surahNumber: 2, ayahNumber: 4),
        startPage: 2,
        preset: HifzPresets.newMemorization,
      ),
      throwsArgumentError,
    );
  });

}
