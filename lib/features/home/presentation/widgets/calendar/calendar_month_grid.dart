import 'package:flutter/material.dart';

import '../../../../../core/localization/app_locale_text.dart';
import '../../../../settings/domain/app_preferences.dart';
import '../../../data/hijri_calendar_month.dart';

class CalendarMonthGrid extends StatelessWidget {
  const CalendarMonthGrid({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.language,
    required this.onSelected,
  });

  final HijriCalendarMonth month;
  final DateTime selectedDate;
  final AppLanguage language;
  final ValueChanged<HijriCalendarDay> onSelected;

  @override
  Widget build(BuildContext context) {
    final leadingBlanks = month.days.isEmpty
        ? 0
        : month.days.first.gregorianDate.weekday % 7;
    final cellCount = leadingBlanks + month.days.length;

    return Column(
      key: const ValueKey('calendar-month-grid'),
      children: [
        Row(
          children: [
            for (final label in _weekdayLabels(language))
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.78,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: cellCount,
          itemBuilder: (context, index) {
            if (index < leadingBlanks) {
              return SizedBox(key: ValueKey('calendar-leading-blank-$index'));
            }
            final day = month.days[index - leadingBlanks];
            return _CalendarDayCell(
              day: day,
              selected: _sameDate(day.gregorianDate, selectedDate),
              language: language,
              onTap: () => onSelected(day),
            );
          },
        ),
      ],
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.selected,
    required this.language,
    required this.onTap,
  });

  final HijriCalendarDay day;
  final bool selected;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final date = day.gregorianDate;
    final key = '${date.year}-${date.month}-${date.day}';
    final primaryText = selected ? scheme.onPrimaryContainer : scheme.onSurface;
    final secondaryText = selected
        ? scheme.onPrimaryContainer.withValues(alpha: 0.72)
        : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label:
          '${day.hijri.day} ${day.hijri.month} ${day.hijri.year}, '
          '${date.day}/${date.month}/${date.year}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          key: ValueKey('calendar-day-$key'),
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localDigits('${day.hijri.day}', language),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: primaryText,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                localDigits('${date.day}', language),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: secondaryText,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 5,
                child: day.events.isEmpty
                    ? null
                    : Center(
                        child: Container(
                          key: ValueKey('calendar-event-dot-$key'),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<String> _weekdayLabels(AppLanguage language) =>
    language == AppLanguage.bangla
    ? const ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি']
    : const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

bool _sameDate(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;
