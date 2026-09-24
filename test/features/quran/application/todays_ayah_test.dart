import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/application/todays_ayah.dart';
import 'package:quran_hifz/features/quran/data/demo_quran_repository.dart';

void main() {
  test(
    'selectTodaysAyah returns the same locally stored ayah all day',
    () async {
      final repository = DemoQuranRepository();

      final morning = await selectTodaysAyah(
        repository: repository,
        date: DateTime(2026, 9, 17, 8),
        translationResourceId: 1,
      );
      final evening = await selectTodaysAyah(
        repository: repository,
        date: DateTime(2026, 9, 17, 20),
        translationResourceId: 1,
      );

      expect(morning, isNotNull);
      expect(morning!.key, evening!.key);
      expect(morning.translation, isNotEmpty);
    },
  );
}
