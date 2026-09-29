import 'package:flutter/material.dart';

import '../../../../../core/localization/app_locale_text.dart';
import '../../../../settings/domain/app_preferences.dart';
import '../../../data/bangla_calendar.dart';
import '../../../data/hijri_calendar_month.dart';
import '../../../data/prayer_schedule.dart';
import 'calendar_event_list.dart';

class CalendarSelectedDayDetails extends StatelessWidget {
  const CalendarSelectedDayDetails({
    super.key,
    required this.day,
    required this.language,
    required this.onShare,
  });

  final HijriCalendarDay day;
  final AppLanguage language;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final schedule = day.schedule;
    final date = day.gregorianDate;
    final weekday = _weekdayName(date.weekday, language);
    final banglaDate = banglaCalendarDate(
      date,
      english: language == AppLanguage.english,
    );

    return Column(
      key: const ValueKey('calendar-selected-details'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localHijriDate(schedule.hijriDate, language),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    weekday + ', ' + localGregorianDate(date, language),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    banglaDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              key: const ValueKey('calendar-share-day'),
              tooltip: appText(language, 'দিনটি শেয়ার করুন', 'Share day'),
              onPressed: onShare,
              icon: const Icon(Icons.share_outlined),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SuhurIftarStrip(schedule: schedule, language: language),
        const SizedBox(height: 14),
        Text(
          appText(language, 'সালাতের সময়', 'Prayer times'),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _PrayerTimes(schedule: schedule, language: language),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                schedule.location,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ProhibitedTimes(schedule: schedule, language: language),
        if (day.events.isNotEmpty) ...[
          const SizedBox(height: 18),
          Column(
            key: const ValueKey('calendar-selected-event-section'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appText(
                  language,
                  'আজকের আমল ও গুরুত্বপূর্ণ দিন',
                  'This day’s reminders',
                ),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    for (var index = 0; index < day.events.length; index++) ...[
                      if (index > 0)
                        Divider(height: 1, color: scheme.outlineVariant),
                      CalendarEventRow(
                        event: day.events[index],
                        language: language,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SuhurIftarStrip extends StatelessWidget {
  const _SuhurIftarStrip({required this.schedule, required this.language});

  final PrayerSchedule schedule;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TimeValue(
              label: appText(language, 'সেহরির শেষ', 'Suhur ends'),
              value: localClock(schedule.times['Fajr'], language),
            ),
          ),
          SizedBox(
            height: 42,
            child: VerticalDivider(width: 1, color: scheme.outlineVariant),
          ),
          Expanded(
            child: _TimeValue(
              label: appText(language, 'ইফতার', 'Iftar'),
              value: localClock(schedule.sunset, language),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTimes extends StatelessWidget {
  const _PrayerTimes({required this.schedule, required this.language});

  final PrayerSchedule schedule;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 32) / 5;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final name in prayerNames)
              SizedBox(
                width: width,
                child: _TimeValue(
                  label: localPrayerName(name, language),
                  value: localClock(schedule.times[name], language),
                  compact: true,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProhibitedTimes extends StatelessWidget {
  const _ProhibitedTimes({required this.schedule, required this.language});

  final PrayerSchedule schedule;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dhuhr = schedule.times['Dhuhr']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.block_rounded, size: 17, color: scheme.error),
            const SizedBox(width: 6),
            Text(
              appText(language, 'নিষিদ্ধ সময়', 'Prohibited times'),
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _AvoidTime(
                label: appText(language, 'সকাল', 'Morning'),
                value: _range(
                  schedule.sunrise,
                  schedule.sunrise.add(const Duration(minutes: 15)),
                  language,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _AvoidTime(
                label: appText(language, 'দুপুর', 'Noon'),
                value: _range(
                  dhuhr.subtract(const Duration(minutes: 5)),
                  dhuhr,
                  language,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _AvoidTime(
                label: appText(language, 'সন্ধ্যা', 'Evening'),
                value: _range(
                  schedule.sunset.subtract(const Duration(minutes: 15)),
                  schedule.sunset,
                  language,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AvoidTime extends StatelessWidget {
  const _AvoidTime({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _TimeValue extends StatelessWidget {
  const _TimeValue({
    required this.label,
    required this.value,
    this.compact = false,
  });

  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 0 : 8,
        vertical: compact ? 4 : 10,
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

String _range(DateTime start, DateTime end, AppLanguage language) =>
    localClock(start, language) + '–' + localClock(end, language);

String _weekdayName(int weekday, AppLanguage language) {
  const bangla = [
    'সোমবার',
    'মঙ্গলবার',
    'বুধবার',
    'বৃহস্পতিবার',
    'শুক্রবার',
    'শনিবার',
    'রবিবার',
  ];
  const english = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return language == AppLanguage.bangla
      ? bangla[weekday - 1]
      : english[weekday - 1];
}
