import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/network/quran_backend_client.dart';
import '../../../core/storage/disk_capacity_storage.dart';
import '../data/bundled_zakaria_tafsir_repository.dart';
import '../data/composite_tafsir_repository.dart';
import '../data/local_tafsir_repository.dart';
import '../data/quran_backend_tafsir_catalog.dart';
import '../data/remote_quran_foundation_tafsir_repository.dart';
import '../data/tafsir_package_installer.dart';
import '../data/tafsir_source_selection_store.dart';
import '../domain/tafsir_catalog.dart';
import '../domain/tafsir_repository.dart';

final quranBackendClientProvider = Provider<QuranBackendClient>((ref) {
  final client = QuranBackendClient();
  ref.onDispose(client.close);
  return client;
});

final tafsirCatalogProvider = Provider<TafsirCatalog>((ref) {
  return QuranBackendTafsirCatalog(ref.watch(quranBackendClientProvider));
});

final tafsirRepositoryProvider = Provider<TafsirRepository>((ref) {
  return CompositeTafsirRepository(
    bundled: BundledZakariaTafsirRepository(rootBundle),
    downloaded: LocalTafsirRepository(ref.watch(userDatabaseProvider)),
    remote: RemoteQuranFoundationTafsirRepository(
      ref.watch(quranBackendClientProvider),
    ),
  );
});

final tafsirSourceSelectionStoreProvider = Provider<TafsirSourceSelectionStore>(
  (ref) {
    return UserDatabaseTafsirSourceSelectionStore(
      ref.watch(userDatabaseProvider),
    );
  },
);

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
