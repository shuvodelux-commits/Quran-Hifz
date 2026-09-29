const _months = [
  'বৈশাখ',
  'জ্যৈষ্ঠ',
  'আষাঢ়',
  'শ্রাবণ',
  'ভাদ্র',
  'আশ্বিন',
  'কার্তিক',
  'অগ্রহায়ণ',
  'পৌষ',
  'মাঘ',
  'ফাল্গুন',
  'চৈত্র',
];

const _englishMonths = [
  'Boishakh',
  'Joishtho',
  'Asharh',
  'Srabon',
  'Bhadro',
  'Ashwin',
  'Kartik',
  'Ogrohayon',
  'Poush',
  'Magh',
  'Falgun',
  'Chaitra',
];

/// Bangladesh's revised Bangla calendar starts on 14 April.
String banglaCalendarDate(DateTime date, {bool english = false}) {
  final parts = _banglaCalendarParts(date);
  return _formatParts(parts, english: english, includeYear: true);
}

String banglaCalendarRange(
  DateTime start,
  DateTime end, {
  bool english = false,
}) {
  final startParts = _banglaCalendarParts(start);
  final endParts = _banglaCalendarParts(end);
  final sameYear = startParts.year == endParts.year;
  final startText = _formatParts(
    startParts,
    english: english,
    includeYear: !sameYear,
  );
  final endText = _formatParts(endParts, english: english, includeYear: true);
  final suffix = english ? '' : ' বঙ্গাব্দ';
  return '$startText – $endText$suffix';
}

_BanglaDateParts _banglaCalendarParts(DateTime date) {
  final startYear = date.month > 4 || (date.month == 4 && date.day >= 14)
      ? date.year
      : date.year - 1;
  final start = DateTime(startYear, 4, 14);
  var dayIndex = DateTime(
    date.year,
    date.month,
    date.day,
  ).difference(start).inDays;
  for (var month = 0; month < _months.length; month++) {
    final length = month < 6
        ? 31
        : month == 10
        ? DateTime(startYear + 1, 4, 14).difference(start).inDays - 336
        : 30;
    if (dayIndex < length) {
      return _BanglaDateParts(
        day: dayIndex + 1,
        monthIndex: month,
        year: startYear - 593,
      );
    }
    dayIndex -= length;
  }
  throw StateError('Date is outside the Bangla year.');
}

String _formatParts(
  _BanglaDateParts parts, {
  required bool english,
  required bool includeYear,
}) {
  final month = english
      ? _englishMonths[parts.monthIndex]
      : _months[parts.monthIndex];
  final value = includeYear
      ? '${parts.day} $month ${parts.year}'
      : '${parts.day} $month';
  return english ? value : _banglaDigits(value);
}

class _BanglaDateParts {
  const _BanglaDateParts({
    required this.day,
    required this.monthIndex,
    required this.year,
  });

  final int day;
  final int monthIndex;
  final int year;
}

String _banglaDigits(String input) => input.replaceAllMapped(
  RegExp(r'\d'),
  (match) => '০১২৩৪৫৬৭৮৯'[int.parse(match.group(0)!)],
);
