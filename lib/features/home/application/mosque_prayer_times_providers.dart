import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../data/mosque_prayer_times_repository.dart';

final mosquePrayerTimesRepositoryProvider =
    Provider<MosquePrayerTimesRepository>(
      (ref) => MosquePrayerTimesRepository(ref.watch(userDatabaseProvider)),
    );

final mosquePrayerTimesProvider =
    FutureProvider.autoDispose<Map<String, MosquePrayerTime>>(
      (ref) => ref.watch(mosquePrayerTimesRepositoryProvider).load(),
    );
