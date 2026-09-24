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
      return english
          ? '${dayIndex + 1} ${_englishMonths[month]} ${startYear - 593}'
          : '${_banglaDigits('${dayIndex + 1}')} ${_months[month]} ${_banglaDigits('${startYear - 593}')}';
    }
    dayIndex -= length;
  }
  throw StateError('Date is outside the Bangla year.');
}

String _banglaDigits(String input) => input.replaceAllMapped(
  RegExp(r'\d'),
  (match) => '০১২৩৪৫৬৭৮৯'[int.parse(match.group(0)!)],
);
