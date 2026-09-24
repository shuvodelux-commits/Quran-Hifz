import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'quran_content_bootstrap.dart';
import 'quran_content_database.dart';
import 'user_database.dart';

final quranContentBootstrapperProvider = Provider<QuranContentBootstrap>((ref) {
  return QuranContentBootstrap.fromBundle();
});

final quranContentBootstrapProvider = FutureProvider<QuranContentDatabase>((
  ref,
) async {
  final database = await ref
      .watch(quranContentBootstrapperProvider)
      .openDatabase();
  ref.onDispose(() {
    unawaited(database.close());
  });
  return database;
});

/// Exposes the verified canonical database produced by the bootstrap future.
///
/// [QuranContentBootstrapGate] renders Quran-dependent UI only after bootstrap
/// has completed, so reads below the gate can synchronously require the value.
/// This avoids nested ProviderScope scoping for an app-wide singleton database.
final quranContentDatabaseProvider = Provider<QuranContentDatabase>((ref) {
  return ref.watch(quranContentBootstrapProvider).requireValue;
});

final userDatabaseProvider = Provider<UserDatabase>((ref) {
  final database = UserDatabase.defaults();
  ref.onDispose(() {
    unawaited(database.close());
  });
  return database;
});
