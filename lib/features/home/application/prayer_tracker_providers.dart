import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../data/prayer_tracker_repository.dart';

final prayerTrackerRepositoryProvider = Provider<PrayerTrackerRepository>(
  (ref) => PrayerTrackerRepository(ref.watch(userDatabaseProvider)),
);

final dailyPrayerChecksProvider = FutureProvider.family<Set<String>, String>(
  (ref, dayKey) => ref.watch(prayerTrackerRepositoryProvider).load(dayKey),
);

Future<void> toggleDailyPrayer(
  WidgetRef ref,
  String dayKey,
  String prayer,
) async {
  await ref.read(prayerTrackerRepositoryProvider).toggle(dayKey, prayer);
  ref.invalidate(dailyPrayerChecksProvider(dayKey));
}
