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
  late int _selectedDay = DateTime.now().day;
  bool _calendarExpanded = false;
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
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: _CompactCalendarSelector(
              year: _year,
              month: _month,
              selectedDay: _selectedDay,
              language: language,
              expanded: _calendarExpanded,
              onToggleExpanded: () =>
                  setState(() => _calendarExpanded = !_calendarExpanded),
              onPreviousMonth: () => _changeMonth(-1),
              onNextMonth: () => _changeMonth(1),
              onMonthChanged: (value) => _setDisplayedMonth(_year, value),
              onYearChanged: (value) => _setDisplayedMonth(value, _month),
              onDaySelected: _selectDay,
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

  void _changeMonth(int delta) {
    final next = DateTime(_year, _month + delta);
    _setDisplayedMonth(next.year, next.month);
  }

  void _setDisplayedMonth(int year, int month) {
    final today = DateTime.now();
    final lastDay = DateTime(year, month + 1, 0).day;
    final isCurrentMonth = year == today.year && month == today.month;
    setState(() {
      _year = year;
      _month = month;
      _selectedDay = isCurrentMonth
          ? today.day
          : _selectedDay.clamp(1, lastDay).toInt();
      _revealedTodayFor = null;
      _dayKeys.clear();
    });
  }

  void _selectDay(int day) {
    setState(() => _selectedDay = day);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToDay(day));
  }

  void _scrollToDay(int day) {
    if (!mounted) return;
    final dayContext = _dayKeys[day]?.currentContext;
    if (dayContext != null) {
      Scrollable.ensureVisible(
        dayContext,
        alignment: 0.05,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    if (_scrollController.hasClients) {
      final dayCount = DateTime(_year, _month + 1, 0).day;
      final position =
          _scrollController.position.maxScrollExtent *
          (day - 1) /
          (dayCount - 1);
      _scrollController.jumpTo(position);
    }
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

class _CompactCalendarSelector extends StatelessWidget {
  const _CompactCalendarSelector({
    required this.year,
    required this.month,
    required this.selectedDay,
    required this.language,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onDaySelected,
  });

  final int year;
  final int month;
  final int selectedDay;
  final AppLanguage language;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final monthName = language == AppLanguage.bangla
        ? _banglaMonths[month - 1]
        : _englishMonths[month - 1];

    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: appText(language, 'আগের মাস', 'Previous month'),
                  visualDensity: VisualDensity.compact,
                  onPressed: onPreviousMonth,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    '$monthName ${localDigits('$year', language)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: appText(language, 'পরের মাস', 'Next month'),
                  visualDensity: VisualDensity.compact,
                  onPressed: onNextMonth,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
                IconButton(
                  key: const ValueKey('calendar-expand-button'),
                  tooltip: expanded
                      ? appText(
                          language,
                          'ক্যালেন্ডার ছোট করুন',
                          'Collapse calendar',
                        )
                      : appText(language, 'পুরো মাস দেখুন', 'Show full month'),
                  visualDensity: VisualDensity.compact,
                  onPressed: onToggleExpanded,
                  icon: Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.calendar_month_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (expanded) ...[
              Row(
                children: [
                  Expanded(
                    child: _Picker<int>(
                      value: month,
                      values: List.generate(12, (index) => index + 1),
                      label: (value) => language == AppLanguage.bangla
                          ? _banglaMonths[value - 1]
                          : _englishMonths[value - 1],
                      onChanged: onMonthChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Picker<int>(
                      value: year,
                      values: List.generate(
                        11,
                        (index) => DateTime.now().year - 5 + index,
                      ),
                      label: (value) => localDigits('$value', language),
                      onChanged: onYearChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _MonthGrid(
                year: year,
                month: month,
                selectedDay: selectedDay,
                language: language,
                onDaySelected: onDaySelected,
              ),
            ] else
              _WeekStrip(
                key: const ValueKey('calendar-week-strip'),
                year: year,
                month: month,
                selectedDay: selectedDay,
                language: language,
                onDaySelected: onDaySelected,
              ),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDay,
    required this.language,
    required this.onDaySelected,
  });

  final int year;
  final int month;
  final int selectedDay;
  final AppLanguage language;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final selected = DateTime(year, month, selectedDay);
    final start = selected.subtract(Duration(days: selected.weekday - 1));
    return Row(
      children: [
        for (var index = 0; index < 7; index++)
          Expanded(
            child: _CalendarDayButton(
              date: start.add(Duration(days: index)),
              displayMonth: month,
              selectedDay: selectedDay,
              language: language,
              onDaySelected: onDaySelected,
            ),
          ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.year,
    required this.month,
    required this.selectedDay,
    required this.language,
    required this.onDaySelected,
  });

  final int year;
  final int month;
  final int selectedDay;
  final AppLanguage language;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(year, month, 1).weekday;
    final dayCount = DateTime(year, month + 1, 0).day;
    final usedCells = firstWeekday - 1 + dayCount;
    final cellCount = ((usedCells + 6) ~/ 7) * 7;
    final labels = language == AppLanguage.bangla
        ? _banglaWeekdayShort
        : _englishWeekdayShort;

    return Column(
      key: const ValueKey('calendar-month-grid'),
      children: [
        Row(
          children: [
            for (final label in labels)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cellCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final day = index - (firstWeekday - 2);
            if (day < 1 || day > dayCount) {
              return const SizedBox.shrink();
            }
            return _CalendarDayButton(
              date: DateTime(year, month, day),
              displayMonth: month,
              selectedDay: selectedDay,
              language: language,
              onDaySelected: onDaySelected,
              showWeekday: false,
            );
          },
        ),
      ],
    );
  }
}

class _CalendarDayButton extends StatelessWidget {
  const _CalendarDayButton({
    required this.date,
    required this.displayMonth,
    required this.selectedDay,
    required this.language,
    required this.onDaySelected,
    this.showWeekday = true,
  });

  final DateTime date;
  final int displayMonth;
  final int selectedDay;
  final AppLanguage language;
  final ValueChanged<int> onDaySelected;
  final bool showWeekday;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final inMonth = date.month == displayMonth;
    final selected = inMonth && date.day == selectedDay;
    final today = DateUtils.isSameDay(date, DateTime.now());
    final labels = language == AppLanguage.bangla
        ? _banglaWeekdayShort
        : _englishWeekdayShort;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: inMonth ? () => onDaySelected(date.day) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showWeekday)
              Text(
                labels[date.weekday - 1],
                maxLines: 1,
                style: TextStyle(
                  fontSize: 9,
                  color: inMonth
                      ? scheme.onSurfaceVariant
                      : scheme.onSurfaceVariant.withValues(alpha: 0.35),
                ),
              ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? scheme.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: !selected && today
                    ? Border.all(color: scheme.primary)
                    : null,
              ),
              child: Text(
                localDigits('${date.day}', language),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected || today
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: !inMonth
                      ? scheme.onSurfaceVariant.withValues(alpha: 0.3)
                      : selected
                      ? scheme.onPrimary
                      : scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
const _banglaWeekdayShort = [
  'সোম',
  'মঙ্গল',
  'বুধ',
  'বৃহ',
  'শুক্র',
  'শনি',
  'রবি',
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
const _englishWeekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
