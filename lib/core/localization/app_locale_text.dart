import '../../features/settings/domain/app_preferences.dart';

String appText(AppLanguage language, String bangla, String english) =>
    language == AppLanguage.bangla ? bangla : english;

String localDigits(String value, AppLanguage language) =>
    language == AppLanguage.english
    ? value
    : value.replaceAllMapped(
        RegExp(r'\d'),
        (match) => '০১২৩৪৫৬৭৮৯'[int.parse(match.group(0)!)],
      );

String localClock(DateTime? value, AppLanguage language) {
  if (value == null) return '—';
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final clock =
      '${hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  return language == AppLanguage.bangla
      ? localDigits(clock, language)
      : '$clock ${value.hour < 12 ? 'AM' : 'PM'}';
}

String localCountdown(Duration value, AppLanguage language) {
  final seconds = value.inSeconds.clamp(0, 86400);
  final text =
      '${(seconds ~/ 3600).toString().padLeft(2, '0')}:'
      '${((seconds % 3600) ~/ 60).toString().padLeft(2, '0')}:'
      '${(seconds % 60).toString().padLeft(2, '0')}';
  return localDigits(text, language);
}

const _gregorianBangla = [
  'জানুয়ারি',
  'ফেব্রুয়ারি',
  'মার্চ',
  'এপ্রিল',
  'মে',
  'জুন',
  'জুলাই',
  'আগস্ট',
  'সেপ্টেম্বর',
  'অক্টোবর',
  'নভেম্বর',
  'ডিসেম্বর',
];
const _gregorianEnglish = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String localGregorianDate(DateTime value, AppLanguage language) {
  final months = language == AppLanguage.bangla
      ? _gregorianBangla
      : _gregorianEnglish;
  return localDigits(
    '${value.day} ${months[value.month - 1]} ${value.year}',
    language,
  );
}

const _hijriMonths = <String, String>{
  'Muharram': 'মুহাররম',
  'Muḥarram': 'মুহাররম',
  'Safar': 'সফর',
  'Ṣafar': 'সফর',
  'Rabi al-Awwal': 'রবিউল আউয়াল',
  'Rabī al-awwal': 'রবিউল আউয়াল',
  'Rabīʿ al-awwal': 'রবিউল আউয়াল',
  'Rabi al-Thani': 'রবিউস সানি',
  'Rabī al-thānī': 'রবিউস সানি',
  'Rabīʿ al-thānī': 'রবিউস সানি',
  'Jumada al-Ula': 'জমাদিউল আউয়াল',
  'Jumada al-Awwal': 'জমাদিউল আউয়াল',
  'Jumādá al-ūlá': 'জমাদিউল আউয়াল',
  'Jumada al-Akhirah': 'জমাদিউস সানি',
  'Jumada al-Thani': 'জমাদিউস সানি',
  'Jumādá al-ākhirah': 'জমাদিউস সানি',
  'Rajab': 'রজব',
  "Sha'ban": 'শাবান',
  'Sha’ban': 'শাবান',
  'Shaʿbān': 'শাবান',
  'Ramadan': 'রমজান',
  'Ramaḍān': 'রমজান',
  'Shawwal': 'শাওয়াল',
  'Shawwāl': 'শাওয়াল',
  "Dhu al-Qi'dah": 'জিলকদ',
  'Dhū al-Qaʿdah': 'জিলকদ',
  'Dhul Qa’dah': 'জিলকদ',
  'Dhul Qadah': 'জিলকদ',
  'Dhu al-Hijjah': 'জিলহজ',
  'Dhū al-Ḥijjah': 'জিলহজ',
  'Dhul Hijjah': 'জিলহজ',
};

String localHijriDate(String value, AppLanguage language) {
  if (language == AppLanguage.english) return value;
  var localized = value.replaceAll(' AH', ' হি.');
  for (final entry in _hijriMonths.entries) {
    localized = localized.replaceAll(entry.key, entry.value);
  }
  return localDigits(localized, language);
}

String localPrayerName(String name, AppLanguage language) =>
    appText(language, switch (name) {
      'Fajr' => 'ফজর',
      'Juma' => 'জুমু‘আহ',
      'Sunrise' => 'সূর্যোদয়',
      'Dhuhr' => 'যোহর',
      'Asr' => 'আসর',
      'Maghrib' => 'মাগরিব',
      'Isha' => 'ইশা',
      _ => name,
    }, name);

String localPrayerNameForDate(
  String name,
  AppLanguage language,
  DateTime date,
) {
  if (name == 'Dhuhr' && date.weekday == DateTime.friday) {
    return appText(language, 'জুমুআ', "Jumu'ah");
  }
  return localPrayerName(name, language);
}
