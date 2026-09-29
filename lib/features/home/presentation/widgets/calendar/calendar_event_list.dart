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
          appText(language, 'এই মাসের গুরুত্বপূর্ণ দিন', 'Monthly reminders'),
          style: language == AppLanguage.english
              ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                )
              : Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 3),
        Column(
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
                  showSource: false,
                )
              else
                CalendarEventRow(
                  event: monthWide[index - entries.length],
                  language: language,
                  showSource: false,
                ),
            ],
          ],
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
    this.showSource = true,
  });

  final IslamicCalendarEvent event;
  final AppLanguage language;
  final int? day;
  final bool showSource;

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (day != null) ...[
            SizedBox(
              width: 26,
              child: Text(
                localDigits('$day', language),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontSize: language == AppLanguage.english ? 13 : null,
                  fontWeight: language == AppLanguage.english
                      ? FontWeight.w400
                      : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      (language == AppLanguage.english
                              ? theme.textTheme.bodySmall
                              : theme.textTheme.bodyMedium)
                          ?.copyWith(
                            fontSize: language == AppLanguage.english
                                ? 13
                                : null,
                            fontWeight: language == AppLanguage.english
                                ? FontWeight.w400
                                : FontWeight.w500,
                          ),
                ),
                if (showSource) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: language == AppLanguage.english ? 12 : null,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.source + ' · ' + grade,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: language == AppLanguage.english ? 11 : null,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
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
