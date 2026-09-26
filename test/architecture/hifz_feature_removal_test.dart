import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Hifz subsystem is removed without deleting Quran Mushaf support', () {
    expect(Directory('lib/features/hifz').existsSync(), isFalse);
    expect(Directory('lib/features/revision').existsSync(), isFalse);
    expect(Directory('lib/features/progress').existsSync(), isFalse);
    expect(Directory('test/features/hifz').existsSync(), isFalse);
    expect(Directory('test/features/revision').existsSync(), isFalse);
    expect(Directory('test/features/progress').existsSync(), isFalse);

    final morePage = File(
      'lib/features/home/presentation/more_page.dart',
    ).readAsStringSync();
    expect(morePage, isNot(contains("features/hifz")));
    expect(morePage, isNot(contains('HifzPlannerPage')));
    expect(morePage, isNot(contains("'Hifz'")));
    expect(morePage, isNot(contains("'হিফজ'")));

    final preferences = File(
      'lib/features/settings/domain/app_preferences.dart',
    ).readAsStringSync();
    expect(preferences, isNot(contains('Hifz')));
    expect(preferences, isNot(contains('hifz')));

    final controller = File(
      'lib/features/settings/application/app_preferences_controller.dart',
    ).readAsStringSync();
    expect(controller, isNot(contains('Hifz')));
    expect(controller, isNot(contains('hifz')));

    final repository = File(
      'lib/features/settings/data/user_database_app_preferences_repository.dart',
    ).readAsStringSync();
    expect(repository, isNot(contains('Hifz')));
    expect(repository, isNot(contains('hifz_')));

    final database = File(
      'lib/core/database/user_database.dart',
    ).readAsStringSync();
    expect(database, isNot(contains('class Hifz')));
    expect(database, isNot(contains('HifzProgressEntries,')));
    expect(database, isNot(contains('HifzReviewHistoryRows,')));
    expect(database, isNot(contains('HifzSessionCheckpoints,')));
    expect(database, isNot(contains('HifzPlans,')));
    expect(database, contains("DROP TABLE IF EXISTS"));
    expect(
      database,
      contains("DELETE FROM app_settings WHERE setting_key LIKE 'hifz_%'"),
    );

    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('assets/mushaf/renderer/'));
    expect(pubspec, contains('assets/mushaf/scripts/'));
    expect(pubspec, contains('assets/mushaf/layouts/'));
    expect(pubspec, isNot(contains('DigitalKhattV2')));
    expect(pubspec, contains('webview_flutter'));
  });
}
