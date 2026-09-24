import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/home/data/prayer_tracker_repository.dart';

void main() {
  test('daily salat checks persist and remain separate across dates', () async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PrayerTrackerRepository(database);

    await repository.toggle('2026-09-14', 'Fajr');
    await repository.toggle('2026-09-14', 'Asr');
    expect(await repository.load('2026-09-14'), {'Fajr', 'Asr'});
    expect(await repository.load('2026-09-15'), isEmpty);

    await repository.toggle('2026-09-14', 'Fajr');
    expect(await repository.load('2026-09-14'), {'Asr'});
  });
}
