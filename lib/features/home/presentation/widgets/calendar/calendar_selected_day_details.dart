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
                    style: language == AppLanguage.english
                        ? theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          )
                        : theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    weekday + ', ' + localGregorianDate(date, language),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: language == AppLanguage.english ? 12 : null,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          banglaDate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontSize: language == AppLanguage.english
                                ? 12
                                : null,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          schedule.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontSize: language == AppLanguage.english
                                ? 12
                                : null,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
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
        const SizedBox(height: 6),
        _SuhurIftarStrip(schedule: schedule, language: language),
        const SizedBox(height: 8),
        _PrayerTimes(schedule: schedule, language: language),
        const SizedBox(height: 6),
        _ProhibitedTimes(schedule: schedule, language: language),
        if (day.events.isNotEmpty) ...[
          const SizedBox(height: 12),
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
                style: language == AppLanguage.english
                    ? theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      )
                    : theme.textTheme.titleSmall,
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
    return Column(
      children: [
        Divider(height: 1, color: scheme.outlineVariant),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: _InlineTimeValue(
                  language: language,
                  label: appText(language, 'সেহরির শেষ', 'Suhur ends'),
                  value: localClock(schedule.times['Fajr'], language),
                ),
              ),
              SizedBox(
                height: 24,
                child: VerticalDivider(width: 1, color: scheme.outlineVariant),
              ),
              Expanded(
                child: _InlineTimeValue(
                  language: language,
                  label: appText(language, 'ইফতার', 'Iftar'),
                  value: localClock(schedule.sunset, language),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: scheme.outlineVariant),
      ],
    );
  }
}

class _InlineTimeValue extends StatelessWidget {
  const _InlineTimeValue({
    required this.language,
    required this.label,
    required this.value,
  });

  final AppLanguage language;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: language == AppLanguage.english ? 11 : null,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: language == AppLanguage.english ? 12 : null,
            fontWeight: language == AppLanguage.english
                ? FontWeight.w400
                : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PrayerTimes extends StatelessWidget {
  const _PrayerTimes({required this.schedule, required this.language});

  final PrayerSchedule schedule;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    if (textScale <= 1.15) {
      return Row(
        children: [
          for (final name in prayerNames)
            Expanded(
              child: _TimeValue(
                language: language,
                label: localPrayerName(name, language),
                value: localClock(schedule.times[name], language),
                compact: true,
              ),
            ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 16) / 3;
        return Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final name in prayerNames)
              SizedBox(
                width: width,
                child: _TimeValue(
                  language: language,
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
    final items = [
      (
        appText(language, 'সকাল', 'Morning'),
        _range(
          schedule.sunrise,
          schedule.sunrise.add(const Duration(minutes: 15)),
          language,
        ),
      ),
      (
        appText(language, 'দুপুর', 'Noon'),
        _range(dhuhr.subtract(const Duration(minutes: 5)), dhuhr, language),
      ),
      (
        appText(language, 'সন্ধ্যা', 'Evening'),
        _range(
          schedule.sunset.subtract(const Duration(minutes: 15)),
          schedule.sunset,
          language,
        ),
      ),
    ];
    final heading = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.block_rounded, size: 15, color: scheme.error),
        const SizedBox(width: 4),
        Text(
          appText(language, 'নিষিদ্ধ সময়', 'Prohibited times'),
          style: language == AppLanguage.english
              ? theme.textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                )
              : theme.textTheme.labelLarge,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading,
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < items.length; index++) ...[
              if (index > 0) const SizedBox(width: 6),
              Expanded(
                child: _AvoidTime(
                  language: language,
                  label: items[index].$1,
                  value: items[index].$2,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _AvoidTime extends StatelessWidget {
  const _AvoidTime({
    required this.language,
    required this.label,
    required this.value,
  });

  final AppLanguage language;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: language == AppLanguage.english ? 11 : null,
            fontWeight: FontWeight.w400,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: language == AppLanguage.english ? 11 : null,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeValue extends StatelessWidget {
  const _TimeValue({
    required this.language,
    required this.label,
    required this.value,
    this.compact = false,
  });

  final AppLanguage language;
  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 1 : 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                (compact
                        ? theme.textTheme.labelSmall
                        : theme.textTheme.labelMedium)
                    ?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: language == AppLanguage.english ? 11 : null,
                      fontWeight: FontWeight.w400,
                    ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            style:
                (compact
                        ? theme.textTheme.bodySmall
                        : theme.textTheme.bodyMedium)
                    ?.copyWith(
                      fontSize: language == AppLanguage.english ? 12 : null,
                      fontWeight: language == AppLanguage.english
                          ? FontWeight.w400
                          : FontWeight.w500,
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
