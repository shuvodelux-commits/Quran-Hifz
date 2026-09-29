import 'hijri_calendar_month.dart';

class IslamicCalendarEvent {
  const IslamicCalendarEvent({
    required this.id,
    required this.titleBangla,
    required this.titleEnglish,
    required this.subtitleBangla,
    required this.subtitleEnglish,
    required this.source,
    required this.gradeBangla,
    required this.gradeEnglish,
    required this.monthWide,
  });

  final String id;
  final String titleBangla;
  final String titleEnglish;
  final String subtitleBangla;
  final String subtitleEnglish;
  final String source;
  final String gradeBangla;
  final String gradeEnglish;
  final bool monthWide;
}

List<IslamicCalendarEvent> islamicEventsFor(HijriDateParts date) {
  final events = <IslamicCalendarEvent>[];

  if (date.month == 'Dhu al-Hijjah' && date.day >= 11 && date.day <= 13) {
    events.add(
      IslamicCalendarEvent(
        id: 'tashriq-${date.day}',
        titleBangla: 'তাশরীকের দিন',
        titleEnglish: 'Day of Tashriq',
        subtitleBangla: 'খাওয়া, পান করা ও আল্লাহর যিকরের দিন।',
        subtitleEnglish: 'A day of eating, drinking, and remembering Allah.',
        source: 'Sahih Muslim 1141a',
        gradeBangla: 'সহিহ',
        gradeEnglish: 'Sahih',
        monthWide: false,
      ),
    );
  } else if (date.day >= 13 && date.day <= 15) {
    final ordinalBangla = switch (date.day) {
      13 => '১ম',
      14 => '২য়',
      _ => '৩য়',
    };
    final ordinalEnglish = switch (date.day) {
      13 => 'Day 1',
      14 => 'Day 2',
      _ => 'Day 3',
    };
    events.add(
      IslamicCalendarEvent(
        id: 'ayyam-al-bid-${date.day}',
        titleBangla: 'আইয়ামে বীয — $ordinalBangla দিন',
        titleEnglish: 'Ayyam al-Bid — $ordinalEnglish',
        subtitleBangla: 'নফল রোজার দিন।',
        subtitleEnglish: 'A recommended voluntary fasting day.',
        source: 'Jamiʿ at-Tirmidhi 761',
        gradeBangla: 'হাসান',
        gradeEnglish: 'Hasan',
        monthWide: false,
      ),
    );
  }

  if (date.month == 'Muharram' && date.day == 10) {
    events.add(
      const IslamicCalendarEvent(
        id: 'ashura-fast',
        titleBangla: 'আশুরার রোজা',
        titleEnglish: 'Fasting Ashura',
        subtitleBangla: '১০ মুহাররমের নফল রোজা।',
        subtitleEnglish: 'Voluntary fasting on 10 Muharram.',
        source: 'Sahih al-Bukhari 1892',
        gradeBangla: 'সহিহ',
        gradeEnglish: 'Sahih',
        monthWide: false,
      ),
    );
  }

  if (date.month == 'Dhu al-Hijjah' && date.day == 9) {
    events.add(
      const IslamicCalendarEvent(
        id: 'arafah-fast',
        titleBangla: 'আরাফার রোজা',
        titleEnglish: 'Fasting Arafah',
        subtitleBangla: '৯ জিলহজের নফল রোজা।',
        subtitleEnglish: 'Voluntary fasting on 9 Dhu al-Hijjah.',
        source: 'Sahih Muslim 1162a',
        gradeBangla: 'সহিহ',
        gradeEnglish: 'Sahih',
        monthWide: false,
      ),
    );
  }

  if (date.month == 'Ramadan' &&
      const <int>{21, 23, 25, 27, 29}.contains(date.day)) {
    events.add(
      IslamicCalendarEvent(
        id: 'laylat-al-qadr-${date.day}',
        titleBangla: 'লাইলাতুল কদর অনুসন্ধানের বিজোড় রাত',
        titleEnglish: 'Odd night to seek Laylat al-Qadr',
        subtitleBangla:
            'রমজানের শেষ দশকের বিজোড় রাতে লাইলাতুল কদর অনুসন্ধান করুন।',
        subtitleEnglish:
            'Seek Laylat al-Qadr in the odd nights of Ramadan’s last ten.',
        source: 'Sahih al-Bukhari 2017',
        gradeBangla: 'সহিহ',
        gradeEnglish: 'Sahih',
        monthWide: false,
      ),
    );
  }

  return events;
}

List<IslamicCalendarEvent> islamicMonthRemindersFor(HijriMonthKey month) {
  if (month.month != 'Shawwal') return const [];

  return const [
    IslamicCalendarEvent(
      id: 'shawwal-six-fasts',
      titleBangla: 'শাওয়ালের ছয় রোজা',
      titleEnglish: 'Six fasts of Shawwal',
      subtitleBangla:
          'শাওয়াল মাসে ছয় দিন রোজা রাখুন; নির্দিষ্ট ছয়টি তারিখ নির্ধারিত নয়।',
      subtitleEnglish:
          'Fast six days in Shawwal; no six fixed dates are prescribed.',
      source: 'Sahih Muslim 1164b/1164c',
      gradeBangla: 'সহিহ',
      gradeEnglish: 'Sahih',
      monthWide: true,
    ),
  ];
}
