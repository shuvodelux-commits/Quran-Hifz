String calendarDayKey(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTime calendarDayStart(DateTime value, {int offsetDays = 0}) {
  if (value.isUtc) {
    return DateTime.utc(value.year, value.month, value.day + offsetDays);
  }
  return DateTime(value.year, value.month, value.day + offsetDays);
}

DateTime calendarDayEnd(DateTime value, {int offsetDays = 0}) {
  final start = calendarDayStart(value, offsetDays: offsetDays + 1);
  return start.subtract(const Duration(microseconds: 1));
}
