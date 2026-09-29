import 'package:flutter/material.dart';

import '../../../../../core/localization/app_locale_text.dart';
import '../../../../settings/domain/app_preferences.dart';
import '../../../data/hijri_calendar_month.dart';
import '../../../data/islamic_calendar_events.dart';

class CalendarEventList extends StatelessWidget {
  const CalendarEventList({
    super.key,
    required this.month,
    required this.language,
  });

  final HijriCalendarMonth month;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final entries = <_CalendarEventEntry>[
      for (final day in month.days)
        for (final event in day.events)
          _CalendarEventEntry(day: day.hijri.day, event: event),
    ]..sort((a, b) => a.day.compareTo(b.day));
    final monthWide = islamicMonthRemindersFor(month.key);

    if (entries.isEmpty && monthWide.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      key: const ValueKey('calendar-month-events'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          appText(
            language,
            'এই মাসের আমল ও গুরুত্বপূর্ণ দিন',
            'This month’s reminders and important days',
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              for (
                var index = 0;
                index < entries.length + monthWide.length;
                index++
              ) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                if (index < entries.length)
                  CalendarEventRow(
                    event: entries[index].event,
                    language: language,
                    day: entries[index].day,
                  )
                else
                  CalendarEventRow(
                    event: monthWide[index - entries.length],
                    language: language,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class CalendarEventRow extends StatelessWidget {
  const CalendarEventRow({
    super.key,
    required this.event,
    required this.language,
    this.day,
  });

  final IslamicCalendarEvent event;
  final AppLanguage language;
  final int? day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = language == AppLanguage.bangla
        ? event.titleBangla
        : event.titleEnglish;
    final subtitle = language == AppLanguage.bangla
        ? event.subtitleBangla
        : event.subtitleEnglish;
    final grade = language == AppLanguage.bangla
        ? event.gradeBangla
        : event.gradeEnglish;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (day != null) ...[
            SizedBox(
              width: 30,
              child: Text(
                localDigits('$day', language),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  event.source + ' · ' + grade,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarEventEntry {
  const _CalendarEventEntry({required this.day, required this.event});

  final int day;
  final IslamicCalendarEvent event;
}
