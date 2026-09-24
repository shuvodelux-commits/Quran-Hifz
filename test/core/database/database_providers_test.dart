import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/quran_content_bootstrap.dart';
import 'package:quran_hifz/core/database/quran_content_database.dart';
import 'package:quran_hifz/core/database/quran_content_installer.dart';

void main() {
  test(
    'canonical database provider exposes completed bootstrap database',
    () async {
      final database = QuranContentDatabase.forTesting(NativeDatabase.memory());
      final bootstrap = QuranContentBootstrap(
        manifestLoader: () async => jsonEncode({
          'content_version': 'test',
          'schema_version': 1,
          'database_sha256':
              'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        }),
        install: (_) async => const QuranContentInstallResult(
          databasePath: '/fixture/quran.sqlite',
          contentVersion: 'test',
          installedNow: false,
        ),
        openDatabase: (_) => database,
      );

      final container = ProviderContainer(
        overrides: [
          quranContentBootstrapperProvider.overrideWithValue(bootstrap),
        ],
      );

      final bootstrapped = await container.read(
        quranContentBootstrapProvider.future,
      );

      expect(bootstrapped, same(database));
      expect(container.read(quranContentDatabaseProvider), same(database));

      container.dispose();
    },
  );
}
