const hijriMonthOrder = <String>[
  'Muharram',
  'Safar',
  'Rabi al-Awwal',
  'Rabi al-Thani',
  'Jumada al-Ula',
  'Jumada al-Akhirah',
  'Rajab',
  "Sha'ban",
  'Ramadan',
  'Shawwal',
  "Dhu al-Qi'dah",
  'Dhu al-Hijjah',
];

class HijriDateParts {
  const HijriDateParts({
    required this.day,
    required this.month,
    required this.year,
  });

  final int day;
  final String month;
  final int year;

  HijriMonthKey get monthKey => HijriMonthKey(month: month, year: year);

  @override
  bool operator ==(Object other) =>
      other is HijriDateParts &&
      other.day == day &&
      other.month == month &&
      other.year == year;

  @override
  int get hashCode => Object.hash(day, month, year);
}

class HijriMonthKey {
  const HijriMonthKey({required this.month, required this.year});

  final String month;
  final int year;

  @override
  bool operator ==(Object other) =>
      other is HijriMonthKey && other.month == month && other.year == year;

  @override
  int get hashCode => Object.hash(month, year);
}

HijriDateParts? parseHijriDate(String value) {
  final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  final match = RegExp(r'^(\d{1,2}) (.+) (\d+) AH$').firstMatch(normalized);
  if (match == null) return null;

  final day = int.tryParse(match.group(1)!);
  final month = match.group(2)!;
  final year = int.tryParse(match.group(3)!);
  if (day == null ||
      day < 1 ||
      day > 30 ||
      year == null ||
      year < 1 ||
      !hijriMonthOrder.contains(month)) {
    return null;
  }

  return HijriDateParts(day: day, month: month, year: year);
}

HijriMonthKey nextHijriMonth(HijriMonthKey current) {
  final index = _monthIndex(current.month);
  if (index == hijriMonthOrder.length - 1) {
    return HijriMonthKey(month: hijriMonthOrder.first, year: current.year + 1);
  }
  return HijriMonthKey(month: hijriMonthOrder[index + 1], year: current.year);
}

HijriMonthKey previousHijriMonth(HijriMonthKey current) {
  final index = _monthIndex(current.month);
  if (index == 0) {
    return HijriMonthKey(month: hijriMonthOrder.last, year: current.year - 1);
  }
  return HijriMonthKey(month: hijriMonthOrder[index - 1], year: current.year);
}

int hijriMonthDelta(HijriMonthKey from, HijriMonthKey to) {
  final fromSerial = from.year * 12 + _monthIndex(from.month);
  final toSerial = to.year * 12 + _monthIndex(to.month);
  return toSerial - fromSerial;
}

int _monthIndex(String month) {
  final index = hijriMonthOrder.indexOf(month);
  if (index < 0) {
    throw ArgumentError.value(month, 'month', 'Unknown Hijri month');
  }
  return index;
}
