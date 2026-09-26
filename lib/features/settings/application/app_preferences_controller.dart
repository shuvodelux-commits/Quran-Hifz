import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../quran/domain/quran_font_preference.dart';
import '../data/user_database_app_preferences_repository.dart';
import '../domain/app_preferences.dart';
import '../domain/app_preferences_repository.dart';

final appPreferencesRepositoryProvider = Provider<AppPreferencesRepository>((
  ref,
) {
  return UserDatabaseAppPreferencesRepository(ref.watch(userDatabaseProvider));
});

final appPreferencesControllerProvider =
    AsyncNotifierProvider<AppPreferencesController, AppPreferences>(
      AppPreferencesController.new,
    );

class AppPreferencesController extends AsyncNotifier<AppPreferences> {
  Future<void> _pendingUpdate = Future<void>.value();

  AppPreferencesRepository get _repository =>
      ref.read(appPreferencesRepositoryProvider);

  @override
  Future<AppPreferences> build() => _repository.load();

  Future<void> setTheme(AppThemePreference value) =>
      _update((current) => current.copyWith(theme: value));

  Future<void> setLanguage(AppLanguage value) =>
      _update((current) => current.copyWith(language: value));

  Future<void> setAsrSchool(AsrSchool value) =>
      _update((current) => current.copyWith(asrSchool: value));

  Future<void> setPrayerCity(String? cityId) => _update(
    (current) => cityId == null
        ? current.copyWith(clearPrayerCity: true)
        : current.copyWith(prayerCityId: cityId),
  );

  Future<void> setQuranScript(QuranScriptPreference value) => _update(
    (current) => current.copyWith(
      quranScript: value,
      quranFont: value == QuranScriptPreference.indoPak
          ? QuranFontPreference.defaultGlobal
          : QuranFontPreference.qpcHafs,
    ),
  );

  Future<void> setQuranFont(QuranFontPreference value) => _update(
    (current) => current.copyWith(quranFont: value, quranScript: value.script),
  );

  Future<void> setArabicFontSize(double value) {
    if (value < 20 || value > 56) {
      throw ArgumentError.value(value, 'value');
    }
    return _update((current) => current.copyWith(arabicFontSize: value));
  }

  Future<void> setArabicLineHeight(double value) {
    if (value < AppPreferences.minArabicLineHeight ||
        value > AppPreferences.maxArabicLineHeight) {
      throw ArgumentError.value(value, 'value');
    }
    return _update((current) => current.copyWith(arabicLineHeight: value));
  }

  Future<void> setBanglaLineHeight(double value) {
    if (value < AppPreferences.minBanglaLineHeight ||
        value > AppPreferences.maxBanglaLineHeight) {
      throw ArgumentError.value(value, 'value');
    }
    return _update((current) => current.copyWith(banglaLineHeight: value));
  }

  Future<void> setBanglaFontSize(double value) {
    if (value < AppPreferences.minBanglaFontSize ||
        value > AppPreferences.maxBanglaFontSize) {
      throw ArgumentError.value(value, 'value');
    }
    return _update((current) => current.copyWith(banglaFontSize: value));
  }

  Future<void> setShowTranslation(bool value) =>
      _update((current) => current.copyWith(showTranslation: value));

  Future<void> setTapToShowTranslation(bool value) =>
      _update((current) => current.copyWith(tapToShowTranslation: value));

  Future<void> setTapToShowBanglaWordMeaning(bool value) =>
      _update((current) => current.copyWith(tapToShowBanglaWordMeaning: value));

  Future<void> setShowTajweedColors(bool value) =>
      _update((current) => current.copyWith(showTajweedColors: value));

  Future<void> setDefaultRepeatCount(int value) {
    if (!AppPreferences.supportedRepeatCounts.contains(value)) {
      throw ArgumentError.value(value, 'value');
    }
    return _update((current) => current.copyWith(defaultRepeatCount: value));
  }

  Future<void> setDefaultPlaybackSpeed(double value) {
    if (!AppPreferences.supportedPlaybackSpeeds.contains(value)) {
      throw ArgumentError.value(value, 'value');
    }
    return _update((current) => current.copyWith(defaultPlaybackSpeed: value));
  }

  Future<void> setRepeatPause(Duration value) {
    if (value.isNegative || value > const Duration(seconds: 10)) {
      throw ArgumentError.value(value, 'value');
    }
    return _update((current) => current.copyWith(repeatPause: value));
  }

  Future<void> setAutoNextAyah(bool value) =>
      _update((current) => current.copyWith(autoNextAyah: value));

  Future<void> setHighlightActiveWord(bool value) =>
      _update((current) => current.copyWith(highlightActiveWord: value));

  Future<void> _update(AppPreferences Function(AppPreferences current) mutate) {
    final update = _pendingUpdate.then((_) => _performUpdate(mutate));
    _pendingUpdate = update.catchError((_) {});
    return update;
  }

  Future<void> _performUpdate(
    AppPreferences Function(AppPreferences current) mutate,
  ) async {
    final current = state.value ?? await _repository.load();
    final next = mutate(current);
    await _repository.save(next);
    state = AsyncData(next);
  }
}

final themePreferenceProvider = Provider<AppThemePreference>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.theme ??
      AppThemePreference.light;
});

final tapToShowTranslationProvider = Provider<bool>(
  (ref) =>
      ref.watch(appPreferencesControllerProvider).value?.tapToShowTranslation ??
      const AppPreferences.defaults().tapToShowTranslation,
);

final tapToShowBanglaWordMeaningProvider = Provider<bool>(
  (ref) =>
      ref
          .watch(appPreferencesControllerProvider)
          .value
          ?.tapToShowBanglaWordMeaning ??
      const AppPreferences.defaults().tapToShowBanglaWordMeaning,
);

final appLanguageProvider = Provider<AppLanguage>(
  (ref) =>
      ref.watch(appPreferencesControllerProvider).value?.language ??
      AppLanguage.bangla,
);

final asrSchoolProvider = Provider<AsrSchool>(
  (ref) =>
      ref.watch(appPreferencesControllerProvider).value?.asrSchool ??
      AsrSchool.hanafi,
);

final prayerCityIdProvider = Provider<String?>(
  (ref) => ref.watch(appPreferencesControllerProvider).value?.prayerCityId,
);

final quranScriptPreferenceProvider = Provider<QuranScriptPreference>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.quranScript ??
      const AppPreferences.defaults().quranScript;
});

final quranFontProvider = Provider<QuranFontPreference>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.quranFont ??
      QuranFontPreference.defaultGlobal;
});

final arabicFontSizeProvider = Provider<double>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.arabicFontSize ??
      const AppPreferences.defaults().arabicFontSize;
});

final arabicLineHeightProvider = Provider<double>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.arabicLineHeight ??
      const AppPreferences.defaults().arabicLineHeight;
});

final banglaLineHeightProvider = Provider<double>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.banglaLineHeight ??
      const AppPreferences.defaults().banglaLineHeight;
});

final banglaFontSizeProvider = Provider<double>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.banglaFontSize ??
      const AppPreferences.defaults().banglaFontSize;
});

final defaultRepeatCountProvider = Provider<int>((ref) {
  return ref
          .watch(appPreferencesControllerProvider)
          .value
          ?.defaultRepeatCount ??
      const AppPreferences.defaults().defaultRepeatCount;
});

final defaultPlaybackSpeedProvider = Provider<double>((ref) {
  return ref
          .watch(appPreferencesControllerProvider)
          .value
          ?.defaultPlaybackSpeed ??
      const AppPreferences.defaults().defaultPlaybackSpeed;
});

final repeatPauseProvider = Provider<Duration>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.repeatPause ??
      const AppPreferences.defaults().repeatPause;
});

final autoNextAyahProvider = Provider<bool>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.autoNextAyah ??
      const AppPreferences.defaults().autoNextAyah;
});

final highlightActiveWordProvider = Provider<bool>((ref) {
  return ref
          .watch(appPreferencesControllerProvider)
          .value
          ?.highlightActiveWord ??
      const AppPreferences.defaults().highlightActiveWord;
});

final showTajweedColorsProvider = Provider<bool>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.showTajweedColors ??
      const AppPreferences.defaults().showTajweedColors;
});

final showTranslationPreferenceProvider = Provider<bool>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.showTranslation ??
      const AppPreferences.defaults().showTranslation;
});
