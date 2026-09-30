import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../application/bangladesh_hijri_date_providers.dart';
import '../../settings/domain/app_preferences.dart';
import '../data/prayer_schedule.dart';
import 'home_page.dart';
import 'nafl_prayer_times_card.dart';

typedef _MonthRequest = ({
  int year,
  int month,
  String location,
  double latitude,
  double longitude,
  int utcOffsetMinutes,
  AsrSchool school,
});

final _monthlyPrayersProvider =
    FutureProvider.family<List<PrayerSchedule>, _MonthRequest>(
      (ref, request) => ref
          .watch(prayerScheduleRepositoryProvider)
          .loadMonth(
            year: request.year,
            month: request.month,
            location: request.location,
            latitude: request.latitude,
            longitude: request.longitude,
            utcOffsetMinutes: request.utcOffsetMinutes,
            school: request.school,
          ),
    );

class PrayerCalendarPage extends ConsumerStatefulWidget {
  const PrayerCalendarPage({super.key});

  @override
  ConsumerState<PrayerCalendarPage> createState() => _PrayerCalendarPageState();
}

class _PrayerCalendarPageState extends ConsumerState<PrayerCalendarPage> {
  late int _year = DateTime.now().year;
  late int _month = DateTime.now().month;
  final _scrollController = ScrollController();
  final _dayKeys = <int, GlobalKey>{};
  ({int year, int month})? _revealedTodayFor;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final current = ref.watch(prayerScheduleProvider);
    final location = current.value;
    final school = ref.watch(asrSchoolProvider);
    final hijriCorrection = ref.watch(hijriDateCorrectionProvider);
    final hijriCorrectionScope = ref.watch(hijriCorrectionScopeProvider);
    final hijriMonth = ref.watch(
      bangladeshHijriMonthProvider((
        year: _year,
        month: _month,
        correction: hijriCorrection,
        correctionScope: hijriCorrectionScope,
      )),
    );
    final request = location == null
        ? null
        : (
            year: _year,
            month: _month,
            location: location.location,
            latitude: location.latitude,
            longitude: location.longitude,
            utcOffsetMinutes: location.utcOffsetMinutes,
            school: school,
          );
    final month = request == null
        ? null
        : ref.watch(_monthlyPrayersProvider(request));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(appText(language, 'ক্যালেন্ডার', 'Calendar')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _Picker<int>(
                    value: _month,
                    values: List.generate(12, (index) => index + 1),
                    label: (value) => language == AppLanguage.bangla
                        ? _banglaMonths[value - 1]
                        : _englishMonths[value - 1],
                    onChanged: (value) => setState(() {
                      _month = value;
                      _revealedTodayFor = null;
                      _dayKeys.clear();
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Picker<int>(
                    value: _year,
                    values: List.generate(
                      11,
                      (index) => DateTime.now().year - 5 + index,
                    ),
                    label: (value) => localDigits('$value', language),
                    onChanged: (value) => setState(() {
                      _year = value;
                      _revealedTodayFor = null;
                      _dayKeys.clear();
                    }),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: request == null
                ? Center(
                    child: current.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('ক্যালেন্ডারের জন্য অবস্থান চালু করুন।'),
                  )
                : month!.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => Center(
                      child: FilledButton.icon(
                        onPressed: () =>
                            ref.invalidate(_monthlyPrayersProvider(request)),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('আবার চেষ্টা করুন'),
                      ),
                    ),
                    data: (days) {
                      _revealTodayAfterLayout();
                      return ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 2, 12, 26),
                        itemCount: days.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final day = DateTime(_year, _month, index + 1);
                          final nextFajr = index + 1 < days.length
                              ? days[index + 1].times['Fajr']
                              : days[index].tomorrowFajr;
                          return _CalendarDayCard(
                            key: _dayKeys.putIfAbsent(
                              index + 1,
                              () => GlobalKey(),
                            ),
                            day: day,
                            schedule: days[index],
                            nextFajr: nextFajr,
                            hijriDate:
                                hijriMonth.value?[index].text ??
                                days[index].hijriDate,
                            language: language,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _revealTodayAfterLayout() {
    final today = DateTime.now();
    if (_year != today.year || _month != today.month) return;
    final monthKey = (year: _year, month: _month);
    if (_revealedTodayFor == monthKey) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _dayKeys[today.day]?.currentContext;
      if (context == null) {
        if (_scrollController.hasClients) {
          final dayCount = DateTime(_year, _month + 1, 0).day;
          final position =
              _scrollController.position.maxScrollExtent *
              (today.day - 1) /
              (dayCount - 1);
          _scrollController.jumpTo(position);
        }
        _revealTodayAfterLayout();
        return;
      }
      _revealedTodayFor = monthKey;
      Scrollable.ensureVisible(
        context,
        alignment: 0.05,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }
}

class _Picker<T> extends StatelessWidget {
  const _Picker({
    required this.value,
    required this.values,
    required this.label,
    required this.onChanged,
  });
  final T value;
  final List<T> values;
  final String Function(T) label;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        items: [
          for (final item in values)
            DropdownMenuItem(value: item, child: Text(label(item))),
        ],
        onChanged: (item) {
          if (item != null) onChanged(item);
        },
      ),
    ),
  );
}

class _CalendarDayCard extends StatelessWidget {
  const _CalendarDayCard({
    super.key,
    required this.day,
    required this.schedule,
    required this.nextFajr,
    required this.hijriDate,
    required this.language,
  });
  final DateTime day;
  final PrayerSchedule schedule;
  final DateTime? nextFajr;
  final String hijriDate;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final header = language == AppLanguage.bangla
        ? '${localGregorianDate(day, language)} · ${_weekdays[day.weekday - 1]}'
        : '${localGregorianDate(day, language)} · ${_englishWeekdays[day.weekday - 1]}';
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 9,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        header,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        localHijriDate(hijriDate, language),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Share day',
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(
                      text:
                          '$header\n${localHijriDate(hijriDate, language)}\n${prayerNames.map((name) => '${localPrayerName(name, language)} ${localClock(schedule.times[name], language)}').join(' · ')}',
                    ),
                  ),
                  icon: Icon(
                    Icons.share_outlined,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _TimeStrip(
                  items: [
                    for (final name in prayerNames)
                      (
                        localPrayerName(name, language),
                        localClock(schedule.times[name], language),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _TimeStrip(
                  items: [
                    (
                      appText(language, 'সূর্যোদয়', 'Sunrise'),
                      localClock(schedule.sunrise, language),
                    ),
                    (
                      appText(language, 'সূর্যাস্ত', 'Sunset'),
                      localClock(schedule.sunset, language),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    appText(
                      language,
                      'সালাতের নিষিদ্ধ সময়',
                      'Prohibited prayer times',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _AvoidChip(
                      appText(language, 'সকাল', 'Morning'),
                      '${localClock(schedule.sunrise, language)}–${localClock(schedule.sunrise.add(const Duration(minutes: 15)), language)}',
                    ),
                    _AvoidChip(
                      appText(language, 'দুপুর', 'Noon'),
                      '${localClock(schedule.times['Dhuhr']!.subtract(const Duration(minutes: 5)), language)}–${localClock(schedule.times['Dhuhr'], language)}',
                    ),
                    _AvoidChip(
                      appText(language, 'সন্ধ্যা', 'Evening'),
                      '${localClock(schedule.sunset.subtract(const Duration(minutes: 15)), language)}–${localClock(schedule.sunset, language)}',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                NaflPrayerTimesCard(
                  schedule: schedule,
                  now: day.add(const Duration(hours: 12)),
                  language: language,
                  nextFajr: nextFajr,
                  embedded: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeStrip extends StatelessWidget {
  const _TimeStrip({required this.items});
  final List<(String, String)> items;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        for (final (label, time) in items)
          Expanded(
            child: Column(
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _AvoidChip extends StatelessWidget {
  const _AvoidChip(this.label, this.time);
  final String label;
  final String time;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: scheme.onPrimaryContainer),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 10)),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _banglaMonths = [
  'জানুয়ারি',
  'ফেব্রুয়ারি',
  'মার্চ',
  'এপ্রিল',
  'মে',
  'জুন',
  'জুলাই',
  'আগস্ট',
  'সেপ্টেম্বর',
  'অক্টোবর',
  'নভেম্বর',
  'ডিসেম্বর',
];
const _weekdays = [
  'সোমবার',
  'মঙ্গলবার',
  'বুধবার',
  'বৃহস্পতিবার',
  'শুক্রবার',
  'শনিবার',
  'রবিবার',
];

const _englishMonths = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const _englishWeekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
