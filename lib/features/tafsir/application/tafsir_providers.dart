import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/network/quran_backend_client.dart';
import '../../../core/storage/disk_capacity_storage.dart';
import '../data/local_tafsir_repository.dart';
import '../data/quran_backend_tafsir_catalog.dart';
import '../data/tafsir_package_installer.dart';
import '../domain/tafsir_catalog.dart';
import '../domain/tafsir_repository.dart';

final tafsirCatalogProvider = Provider<TafsirCatalog>((ref) {
  final client = QuranBackendClient();
  ref.onDispose(client.close);
  return QuranBackendTafsirCatalog(client);
});

final tafsirRepositoryProvider = Provider<TafsirRepository>((ref) {
  return LocalTafsirRepository(ref.watch(userDatabaseProvider));
});

final tafsirPackageInstallerProvider = Provider<TafsirPackageInstaller>((ref) {
  final quranDatabase = ref.watch(quranContentDatabaseProvider);
  final transport = DartIoTafsirPackageTransport();
  final installer = TafsirPackageInstaller(
    database: ref.watch(userDatabaseProvider),
    rootDirectory: getApplicationSupportDirectory,
    transport: transport,
    storageCapacity: DiskCapacityStorage(),
    canonicalAyahBounds: () async {
      final surahs = await quranDatabase.select(quranDatabase.surahs).get();
      return {for (final surah in surahs) surah.number: surah.ayahCount};
    },
  );
  ref.onDispose(installer.dispose);
  return installer;
});
