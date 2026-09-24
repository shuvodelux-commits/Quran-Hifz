import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/prayer_tracker_providers.dart';
import '../data/prayer_schedule.dart';
import 'home_page.dart' show prayerScheduleProvider;

class PrayerTrackerPage extends ConsumerWidget {
  const PrayerTrackerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final now = DateTime.now();
    final key =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final completed =
        ref.watch(dailyPrayerChecksProvider(key)).value ?? <String>{};
    final schedule = ref.watch(prayerScheduleProvider).value;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(appText(language, 'সলাত ট্র্যাকার', 'Salat tracker')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appText(language, 'আজকের সলাত', 'Today’s prayers'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  appText(
                    language,
                    '${localDigits('${completed.length}', language)} / ৫ সম্পন্ন',
                    '${completed.length} of 5 completed',
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: completed.length / 5,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withValues(alpha: 0.3),
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final name in prayerNames)
            Card(
              margin: const EdgeInsets.only(bottom: 9),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                onTap: () => toggleDailyPrayer(ref, key, name),
                leading: Icon(
                  name == 'Isha'
                      ? Icons.nights_stay_outlined
                      : Icons.mosque_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  localPrayerName(name, language),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(_window(name, schedule, language)),
                trailing: Icon(
                  completed.contains(name)
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: completed.contains(name)
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            appText(
              language,
              'সলাতে চাপ দিয়ে সম্পন্ন হিসেবে চিহ্নিত করুন। প্রতিদিনের হিসাব সংরক্ষিত থাকে।',
              'Tap a prayer to mark it complete. Your checks are saved for each date.',
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _window(String name, PrayerSchedule? schedule, AppLanguage language) {
    if (schedule == null)
      return appText(language, 'সময় পাওয়া যায়নি', 'Time unavailable');
    final start = schedule.times[name];
    final end = switch (name) {
      'Fajr' => schedule.sunrise,
      'Dhuhr' => schedule.times['Asr'],
      'Asr' => schedule.times['Maghrib'],
      'Maghrib' => schedule.times['Isha'],
      'Isha' => schedule.tomorrowFajr,
      _ => null,
    };
    if (start == null)
      return appText(language, 'সময় পাওয়া যায়নি', 'Time unavailable');
    return end == null
        ? localClock(start, language)
        : '${localClock(start, language)} – ${localClock(end, language)}';
  }
}
