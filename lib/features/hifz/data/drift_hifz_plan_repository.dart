import 'package:drift/drift.dart';

import '../../../core/database/user_database.dart';
import '../domain/hifz_plan.dart';
import '../domain/hifz_preset.dart';
import '../domain/hifz_session.dart';

class DriftHifzPlanRepository implements HifzPlanRepository {
  DriftHifzPlanRepository(this._database);

  final UserDatabase _database;

  @override
  Stream<List<HifzPlan>> watchPlans(String profileKey) {
    final query = _database.select(_database.hifzPlans)
      ..where((row) => row.profileKey.equals(profileKey))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);
    return query.watch().map(
      (rows) => rows.map(_planFromRow).toList(growable: false),
    );
  }

  @override
  Future<int> createPlan({
    required String profileKey,
    required String title,
    required AyahRef start,
    required AyahRef end,
    required int startPage,
    required HifzPreset preset,
  }) {
    if (start.surahNumber != end.surahNumber ||
        start.ayahNumber <= 0 ||
        end.ayahNumber < start.ayahNumber) {
      throw ArgumentError('A Hifz plan must be a valid same-Surah range.');
    }
    if (startPage < 1 || startPage > 604) {
      throw ArgumentError.value(startPage, 'startPage');
    }
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Plan title cannot be empty.');
    }
    final now = DateTime.now().toUtc();
    return _database
        .into(_database.hifzPlans)
        .insert(
          HifzPlansCompanion.insert(
            profileKey: profileKey,
            title: normalizedTitle,
            startSurah: start.surahNumber,
            startAyah: start.ayahNumber,
            endSurah: end.surahNumber,
            endAyah: end.ayahNumber,
            startPage: startPage,
            presetId: preset.id,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  @override
  Future<void> updatePreset(int id, HifzPreset preset) async {
    final affected = await (_database.update(
      _database.hifzPlans,
    )..where((row) => row.id.equals(id))).write(
      HifzPlansCompanion(
        presetId: Value(preset.id),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    if (affected != 1) {
      throw StateError('Hifz plan $id was not found.');
    }
  }

  @override
  Future<void> deletePlan(int id) async {
    await (_database.delete(
      _database.hifzPlans,
    )..where((row) => row.id.equals(id))).go();
  }

  HifzPlan _planFromRow(HifzPlanRow row) => HifzPlan(
    id: row.id,
    profileKey: row.profileKey,
    title: row.title,
    start: AyahRef(surahNumber: row.startSurah, ayahNumber: row.startAyah),
    end: AyahRef(surahNumber: row.endSurah, ayahNumber: row.endAyah),
    startPage: row.startPage,
    preset: HifzPresets.fromId(row.presetId),
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
  );
}
