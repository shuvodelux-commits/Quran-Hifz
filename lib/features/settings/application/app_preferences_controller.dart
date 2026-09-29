import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../quran/domain/quran_font_preference.dart';
import '../../quran/domain/quran_mushaf_variant.dart';
import '../../hifz/domain/hifz_reader_mode.dart';
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

  Future<void> setTheme(AppThemePreference value) => _update(
    (current) => current.copyWith(
      theme: value,
      accent: value == AppThemePreference.dark
          ? AppAccentPreference.graphite
          : AppAccentPreference.sky,
    ),
  );

  Future<void> setAccent(AppAccentPreference value) =>
      _update((current) => current.copyWith(accent: value));

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
          ? QuranFontPreference.indoPak
          : QuranFontPreference.qpcHafs,
    ),
  );

  Future<void> setQuranFont(QuranFontPreference value) => _update(
    (current) => current.copyWith(quranFont: value, quranScript: value.script),
  );

  Future<void> setHifzMushafVariant(QuranMushafVariant value) =>
      _update((current) => current.copyWith(hifzMushafVariant: value));

  Future<void> setHifzFontSize(double value) {
    if (!value.isFinite ||
        value < AppPreferences.minHifzFontSize ||
        value > AppPreferences.maxHifzFontSize) {
      throw ArgumentError.value(value, 'value');
    }
    return _update((current) => current.copyWith(hifzFontSize: value));
  }

  Future<void> setHifzLineHeight(double value) {
    if (!value.isFinite ||
        value < AppPreferences.minHifzLineHeight ||
        value > AppPreferences.maxHifzLineHeight) {
      throw ArgumentError.value(value, 'value');
    }
    return _update((current) => current.copyWith(hifzLineHeight: value));
  }

  Future<void> setHifzShowTajweedColors(bool value) =>
      _update((current) => current.copyWith(hifzShowTajweedColors: value));

  Future<void> setHifzReaderMode(HifzReaderMode value) =>
      _update((current) => current.copyWith(hifzReaderMode: value));

  Future<void> setHifzContinuousAutoScrollEnabled(bool value) => _update(
    (current) => current.copyWith(hifzContinuousAutoScrollEnabled: value),
  );

  Future<void> setHifzAutoScrollSpeed(double value) {
    if (!value.isFinite || value < 0 || value > 1) {
      throw ArgumentError.value(value, 'value');
    }
    return _update((current) => current.copyWith(hifzAutoScrollSpeed: value));
  }

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

  Future<void> setShowPlaybackBanglaWordMeaning(bool value) => _update(
    (current) => current.copyWith(showPlaybackBanglaWordMeaning: value),
  );

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

final accentPreferenceProvider = Provider<AppAccentPreference>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.accent ??
      const AppPreferences.defaults().accent;
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

final showPlaybackBanglaWordMeaningProvider = Provider<bool>(
  (ref) =>
      ref
          .watch(appPreferencesControllerProvider)
          .value
          ?.showPlaybackBanglaWordMeaning ??
      const AppPreferences.defaults().showPlaybackBanglaWordMeaning,
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

final hifzMushafVariantProvider = Provider<QuranMushafVariant>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.hifzMushafVariant ??
      const AppPreferences.defaults().hifzMushafVariant;
});

final hifzFontSizeProvider = Provider<double>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.hifzFontSize ??
      const AppPreferences.defaults().hifzFontSize;
});

final hifzLineHeightProvider = Provider<double>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.hifzLineHeight ??
      const AppPreferences.defaults().hifzLineHeight;
});

final hifzShowTajweedColorsProvider = Provider<bool>((ref) {
  return ref
          .watch(appPreferencesControllerProvider)
          .value
          ?.hifzShowTajweedColors ??
      const AppPreferences.defaults().hifzShowTajweedColors;
});

final hifzReaderModeProvider = Provider<HifzReaderMode>((ref) {
  return ref.watch(appPreferencesControllerProvider).value?.hifzReaderMode ??
      const AppPreferences.defaults().hifzReaderMode;
});

final hifzContinuousAutoScrollEnabledProvider = Provider<bool>((ref) {
  return ref
          .watch(appPreferencesControllerProvider)
          .value
          ?.hifzContinuousAutoScrollEnabled ??
      const AppPreferences.defaults().hifzContinuousAutoScrollEnabled;
});

final hifzAutoScrollSpeedProvider = Provider<double>((ref) {
  return ref
          .watch(appPreferencesControllerProvider)
          .value
          ?.hifzAutoScrollSpeed ??
      const AppPreferences.defaults().hifzAutoScrollSpeed;
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
