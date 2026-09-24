import '../../../core/localization/app_locale_text.dart';
import '../../settings/domain/app_preferences.dart';
import '../domain/dua.dart';

String duaSourcePrimary(DuaSource source, AppLanguage language) {
  return switch (source.type) {
    DuaSourceType.quran => _quranReference(source, language),
    DuaSourceType.hadith =>
      '${source.collection ?? ''} ${localDigits(source.reference ?? '', language)}'
          .trim(),
  };
}

String? duaSourceGrade(DuaSource source, AppLanguage language) {
  final grade = source.grade;
  if (grade == null) return null;
  return switch (grade) {
    HadithGrade.sahih => appText(language, 'সহিহ', 'Sahih'),
    HadithGrade.hasan => appText(language, 'হাসান', 'Hasan'),
  };
}

String _quranReference(DuaSource source, AppLanguage language) {
  final surah = source.surahNumber;
  final start = source.ayahStart;
  if (surah == null || start == null) {
    return appText(language, 'কুরআন', "Qur'an");
  }
  final end = source.ayahEnd;
  final ayah = end != null && end != start ? '$start-$end' : '$start';
  final numeric = localDigits('$surah:$ayah', language);
  return appText(language, 'কুরআন $numeric', "Qur'an $numeric");
}
