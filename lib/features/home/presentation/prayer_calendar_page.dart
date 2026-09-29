import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../data/bangla_calendar.dart';
import '../data/hijri_calendar_month.dart';
import '../data/prayer_schedule.dart';
import 'home_page.dart';
import 'widgets/calendar/calendar_event_list.dart';
import 'widgets/calendar/calendar_month_grid.dart';
import 'widgets/calendar/calendar_selected_day_details.dart';

typedef _HijriMonthRequest = ({
  HijriMonthKey target,
  DateTime anchorDate,
  String location,
  double latitude,
  double longitude,
  int utcOffsetMinutes,
  AsrSchool school,
});

final _hijriCalendarMonthProvider =
    FutureProvider.family<HijriCalendarMonth, _HijriMonthRequest>((
      ref,
      request,
    ) {
      final loader = HijriCalendarMonthLoader(
        ref.watch(prayerScheduleRepositoryProvider),
      );
      return loader.load(
        target: request.target,
        anchorDate: request.anchorDate,
        location: request.location,
        latitude: request.latitude,
        longitude: request.longitude,
        utcOffsetMinutes: request.utcOffsetMinutes,
        school: request.school,
      );
    });

class PrayerCalendarPage extends ConsumerStatefulWidget {
  const PrayerCalendarPage({super.key});

  @override
  ConsumerState<PrayerCalendarPage> createState() => _PrayerCalendarPageState();
}

class _PrayerCalendarPageState extends ConsumerState<PrayerCalendarPage> {
  HijriMonthKey? _target;
  DateTime? _anchorDate;
  DateTime? _selectedDate;
  HijriCalendarMonth? _lastLoadedMonth;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final current = ref.watch(prayerScheduleProvider);
    final schedule = current.value;

    if (schedule == null) {
      return Scaffold(
        appBar: _appBar(language),
        body: Center(
          child: current.isLoading
              ? const CircularProgressIndicator()
              : Text(
                  appText(
                    language,
                    'দিনপঞ্জিকার জন্য অবস্থান চালু করুন।',
                    'Enable a location to use the calendar.',
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      );
    }

    final parsedCurrent = parseHijriDate(schedule.hijriDate);
    if (parsedCurrent == null) {
      return Scaffold(
        appBar: _appBar(language),
        body: Center(
          child: Text(
            appText(
              language,
              'হিজরি তারিখ পাওয়া যায়নি।',
              'Hijri calendar date is unavailable.',
            ),
          ),
        ),
      );
    }

    final target = _target ?? parsedCurrent.monthKey;
    final anchor = _anchorDate ?? _dateOnly(schedule.sunrise);
    final school = ref.watch(asrSchoolProvider);
    final request = (
      target: target,
      anchorDate: anchor,
      location: schedule.location,
      latitude: schedule.latitude,
      longitude: schedule.longitude,
      utcOffsetMinutes: schedule.utcOffsetMinutes,
      school: school,
    );
    final monthValue = ref.watch(_hijriCalendarMonthProvider(request));
    final loadedMonth = monthValue.value;
    if (loadedMonth != null) {
      _lastLoadedMonth = loadedMonth;
    }

    return Scaffold(
      appBar: _appBar(language),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 2, 14, 18),
          children: [
            _MonthNavigationHeader(
              target: target,
              month: loadedMonth,
              language: language,
              onPrevious: () => _navigate(
                direction: -1,
                currentTarget: target,
                currentAnchor: anchor,
                loadedMonth: loadedMonth,
              ),
              onNext: () => _navigate(
                direction: 1,
                currentTarget: target,
                currentAnchor: anchor,
                loadedMonth: loadedMonth,
              ),
              onPickMonth: () => _showMonthPicker(
                currentTarget: target,
                currentAnchor: anchor,
                language: language,
              ),
            ),
            const SizedBox(height: 4),
            monthValue.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => _CalendarLoadError(
                language: language,
                onRetry: () =>
                    ref.invalidate(_hijriCalendarMonthProvider(request)),
              ),
              data: (month) => _CalendarMonthContent(
                month: month,
                selectedDate: _selectedDateFor(month),
                language: language,
                onSelected: (day) {
                  setState(() => _selectedDate = day.gregorianDate);
                },
                onShare: (day) => _shareDay(day, language),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _appBar(AppLanguage language) => AppBar(
    toolbarHeight: 44,
    title: Text(
      appText(language, 'দিনপঞ্জিকা', 'Calendar'),
      style: language == AppLanguage.english
          ? Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            )
          : Theme.of(context).textTheme.titleMedium,
    ),
    centerTitle: true,
  );

  DateTime _selectedDateFor(HijriCalendarMonth month) {
    final explicit = _selectedDate;
    if (explicit != null &&
        month.days.any(
          (day) => DateUtils.isSameDay(day.gregorianDate, explicit),
        )) {
      return explicit;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (month.days.any(
      (day) => DateUtils.isSameDay(day.gregorianDate, today),
    )) {
      return today;
    }
    return month.days.first.gregorianDate;
  }

  void _navigate({
    required int direction,
    required HijriMonthKey currentTarget,
    required DateTime currentAnchor,
    required HijriCalendarMonth? loadedMonth,
  }) {
    final nextTarget = direction > 0
        ? nextHijriMonth(currentTarget)
        : previousHijriMonth(currentTarget);
    final known = loadedMonth?.key == currentTarget
        ? loadedMonth
        : (_lastLoadedMonth?.key == currentTarget ? _lastLoadedMonth : null);

    final nextAnchor = known == null
        ? HijriCalendarMonthLoader(
            ref.read(prayerScheduleRepositoryProvider),
          ).estimateAnchor(
            from: currentTarget,
            fromAnchor: currentAnchor,
            to: nextTarget,
          )
        : direction > 0
        ? known.days.last.gregorianDate.add(const Duration(days: 1))
        : known.days.first.gregorianDate.subtract(const Duration(days: 1));

    setState(() {
      _target = nextTarget;
      _anchorDate = _dateOnly(nextAnchor);
      _selectedDate = null;
    });
  }

  Future<void> _showMonthPicker({
    required HijriMonthKey currentTarget,
    required DateTime currentAnchor,
    required AppLanguage language,
  }) async {
    var selectedMonth = currentTarget.month;
    var selectedYear = currentTarget.year;
    final years = [
      for (
        var year = currentTarget.year - 5;
        year <= currentTarget.year + 5;
        year++
      )
        year,
    ];

    final picked = await showModalBottomSheet<HijriMonthKey>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: SingleChildScrollView(
              key: const ValueKey('calendar-month-picker'),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    appText(language, 'হিজরি মাস', 'Hijri month'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final month in hijriMonthOrder)
                        ChoiceChip(
                          label: Text(localHijriMonthName(month, language)),
                          selected: selectedMonth == month,
                          onSelected: (_) {
                            setSheetState(() => selectedMonth = month);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: const ValueKey('calendar-hijri-year-picker'),
                    initialValue: selectedYear,
                    decoration: InputDecoration(
                      labelText: appText(language, 'হিজরি বছর', 'Hijri year'),
                    ),
                    items: [
                      for (final year in years)
                        DropdownMenuItem(
                          value: year,
                          child: Text(localDigits('$year', language)),
                        ),
                    ],
                    onChanged: (year) {
                      if (year != null) {
                        setSheetState(() => selectedYear = year);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const ValueKey('calendar-month-picker-confirm'),
                    onPressed: () => Navigator.of(sheetContext).pop(
                      HijriMonthKey(month: selectedMonth, year: selectedYear),
                    ),
                    child: Text(appText(language, 'দেখুন', 'View month')),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (picked == null || !mounted) return;
    final anchor =
        HijriCalendarMonthLoader(
          ref.read(prayerScheduleRepositoryProvider),
        ).estimateAnchor(
          from: currentTarget,
          fromAnchor: currentAnchor,
          to: picked,
        );
    setState(() {
      _target = picked;
      _anchorDate = _dateOnly(anchor);
      _selectedDate = null;
    });
  }

  Future<void> _shareDay(HijriCalendarDay day, AppLanguage language) {
    return SharePlus.instance.share(
      ShareParams(
        text: calendarShareText(
          day: day.gregorianDate,
          schedule: day.schedule,
          language: language,
        ),
      ),
    );
  }
}

class _MonthNavigationHeader extends StatelessWidget {
  const _MonthNavigationHeader({
    required this.target,
    required this.month,
    required this.language,
    required this.onPrevious,
    required this.onNext,
    required this.onPickMonth,
  });

  final HijriMonthKey target;
  final HijriCalendarMonth? month;
  final AppLanguage language;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPickMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loaded = month;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              key: const ValueKey('calendar-previous-month'),
              tooltip: appText(language, 'আগের মাস', 'Previous month'),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: TextButton(
                key: const ValueKey('calendar-month-title'),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onPickMonth,
                child: Text(
                  localHijriMonthName(target.month, language) +
                      ' ' +
                      localDigits(target.year.toString(), language),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontSize: language == AppLanguage.english ? 14 : null,
                    fontWeight: language == AppLanguage.english
                        ? FontWeight.w400
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
            IconButton(
              key: const ValueKey('calendar-next-month'),
              tooltip: appText(language, 'পরের মাস', 'Next month'),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        if (loaded != null && loaded.days.isNotEmpty) ...[
          Text(
            localGregorianDateRange(
              loaded.days.first.gregorianDate,
              loaded.days.last.gregorianDate,
              language,
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: language == AppLanguage.english ? 12 : null,
              fontWeight: FontWeight.w400,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            banglaCalendarRange(
              loaded.days.first.gregorianDate,
              loaded.days.last.gregorianDate,
              english: language == AppLanguage.english,
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: language == AppLanguage.english ? 12 : null,
              fontWeight: FontWeight.w400,
              height: 1.15,
            ),
          ),
        ],
      ],
    );
  }
}

class _CalendarMonthContent extends StatelessWidget {
  const _CalendarMonthContent({
    required this.month,
    required this.selectedDate,
    required this.language,
    required this.onSelected,
    required this.onShare,
  });

  final HijriCalendarMonth month;
  final DateTime selectedDate;
  final AppLanguage language;
  final ValueChanged<HijriCalendarDay> onSelected;
  final ValueChanged<HijriCalendarDay> onShare;

  @override
  Widget build(BuildContext context) {
    final selectedDay = month.days.firstWhere(
      (day) => DateUtils.isSameDay(day.gregorianDate, selectedDate),
      orElse: () => month.days.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CalendarMonthGrid(
          month: month,
          selectedDate: selectedDay.gregorianDate,
          language: language,
          onSelected: onSelected,
        ),
        const SizedBox(height: 6),
        Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
        const SizedBox(height: 6),
        CalendarSelectedDayDetails(
          day: selectedDay,
          language: language,
          onShare: () => onShare(selectedDay),
        ),
        const SizedBox(height: 14),
        CalendarEventList(month: month, language: language),
      ],
    );
  }
}

class _CalendarLoadError extends StatelessWidget {
  const _CalendarLoadError({required this.language, required this.onRetry});

  final AppLanguage language;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44),
      child: Center(
        child: FilledButton.icon(
          key: const ValueKey('calendar-retry'),
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(appText(language, 'আবার চেষ্টা করুন', 'Try again')),
        ),
      ),
    );
  }
}

String calendarShareText({
  required DateTime day,
  required PrayerSchedule schedule,
  required AppLanguage language,
}) {
  final lines = <String>[
    localHijriDate(schedule.hijriDate, language),
    localGregorianDate(day, language),
    banglaCalendarDate(day, english: language == AppLanguage.english),
    for (final name in prayerNames)
      localPrayerName(name, language) +
          ' ' +
          localClock(schedule.times[name], language),
  ];
  return lines.join('\n');
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
