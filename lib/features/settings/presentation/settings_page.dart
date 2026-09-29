import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../home/data/bangladesh_cities.dart';
import '../../home/presentation/prayer_location_page.dart';
import '../../quran/application/quran_providers.dart';
import '../../quran/domain/bismillah_text.dart';
import '../../quran/domain/quran_font_preference.dart';
import '../../quran/presentation/quran_text_style.dart';
import '../../quran/presentation/widgets/quran_tajweed_text.dart';
import '../../reciters/presentation/reciter_audio_page.dart';
import '../application/app_preferences_controller.dart';
import '../domain/app_preferences.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key, this.currentSurahNumber = 1});

  final int currentSurahNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesControllerProvider);
    final language = ref.watch(appLanguageProvider);
    final indoPakAvailable =
        ref.watch(indoPakQuranTextAvailableProvider).value ?? false;
    final tajweedAvailable =
        ref.watch(tajweedQuranTextAvailableProvider).value ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(appText(language, 'সেটিংস', 'Settings'))),
      body: preferences.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(appPreferencesControllerProvider),
            child: const Text('Retry'),
          ),
        ),
        data: (value) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            _SettingsSectionHeader(
              icon: Icons.palette_outlined,
              title: appText(
                value.language,
                'অ্যাপের রূপ ও ভাষা',
                'Appearance & Language',
              ),
              subtitle: appText(
                value.language,
                'ভাষা ও UI রং বেছে নিন',
                'Choose app language and UI color',
              ),
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-language-card'),
              children: [
                DropdownButtonFormField<AppLanguage>(
                  initialValue: value.language,
                  decoration: InputDecoration(
                    labelText: value.language == AppLanguage.bangla
                        ? 'অ্যাপের ভাষা'
                        : 'App language',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AppLanguage.bangla,
                      child: Text('বাংলা'),
                    ),
                    DropdownMenuItem(
                      value: AppLanguage.english,
                      child: Text('English'),
                    ),
                  ],
                  onChanged: (language) {
                    if (language != null) {
                      ref
                          .read(appPreferencesControllerProvider.notifier)
                          .setLanguage(language);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-theme-card'),
              children: [
                Text(
                  appText(value.language, 'UI রং', 'UI color'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                _ThemePicker(
                  language: value.language,
                  selected: value.theme,
                  onSelected: (theme) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setTheme(theme),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsSectionHeader(
              icon: Icons.mosque_outlined,
              title: appText(
                value.language,
                'সালাত ও অবস্থান',
                'Prayer & Location',
              ),
              subtitle: appText(
                value.language,
                'আসরের গণনা ও নামাজের অবস্থান',
                'Asr calculation and prayer location',
              ),
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-asr-card'),
              children: [
                DropdownButtonFormField<AsrSchool>(
                  initialValue: value.asrSchool,
                  decoration: InputDecoration(
                    labelText: value.language == AppLanguage.bangla
                        ? 'আসরের সময় গণনা'
                        : 'Asr time calculation',
                    helperText: 'University of Islamic Sciences, Karachi',
                  ),
                  items: [
                    DropdownMenuItem(
                      value: AsrSchool.standard,
                      child: Text(
                        value.language == AppLanguage.bangla
                            ? 'আহলে হাদিস · ছায়া ১ গুণ'
                            : 'Ahle Hadith · shadow 1×',
                      ),
                    ),
                    DropdownMenuItem(
                      value: AsrSchool.hanafi,
                      child: Text(
                        value.language == AppLanguage.bangla
                            ? 'হানাফি · ছায়া ২ গুণ'
                            : 'Hanafi · shadow 2×',
                      ),
                    ),
                  ],
                  onChanged: (school) {
                    if (school != null) {
                      ref
                          .read(appPreferencesControllerProvider.notifier)
                          .setAsrSchool(school);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-location-card'),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(
                    value.language == AppLanguage.bangla
                        ? 'অবস্থান · বাংলাদেশ'
                        : 'Location · Bangladesh',
                  ),
                  subtitle: Text(
                    value.prayerCityId == null
                        ? (value.language == AppLanguage.bangla
                              ? 'GPS অবস্থান'
                              : 'GPS location')
                        : (value.language == AppLanguage.bangla
                                  ? bangladeshCityById(
                                      value.prayerCityId,
                                    )?.bnName
                                  : bangladeshCityById(
                                      value.prayerCityId,
                                    )?.name) ??
                              '—',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PrayerLocationPage(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsSectionHeader(
              icon: Icons.menu_book_outlined,
              title: appText(value.language, 'কুরআন পড়া', 'Quran Reading'),
              subtitle: appText(
                value.language,
                'ফন্ট, তাজবিদ ও ট্যাপ আচরণ',
                'Font, Tajweed and tap behavior',
              ),
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-quran-font-card'),
              children: [
                DropdownButtonFormField<QuranFontPreference>(
                  initialValue: value.quranFont,
                  decoration: InputDecoration(
                    labelText: appText(
                      value.language,
                      'আরবি কুরআনের ফন্ট',
                      'Arabic Quran font',
                    ),
                    helperText: indoPakAvailable
                        ? appText(
                            value.language,
                            'ফন্ট বাছলে উপযুক্ত লিখনরীতি স্বয়ংক্রিয়ভাবে বাছা হবে।',
                            'Selecting a font automatically selects its compatible script.',
                          )
                        : appText(
                            value.language,
                            'ইন্দো-পাকের জন্য নতুন কুরআন ডেটা প্রয়োজন।',
                            'IndoPak needs the updated dual-script Quran content package.',
                          ),
                  ),
                  items: QuranFontPreference.values
                      .map(
                        (font) => DropdownMenuItem(
                          value: font,
                          child: Text(font.label),
                        ),
                      )
                      .toList(),
                  onChanged: (font) {
                    if (font != null) {
                      ref
                          .read(appPreferencesControllerProvider.notifier)
                          .setQuranFont(font);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-tajweed-card'),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    appText(value.language, 'তাজবিদের রং', 'Tajweed colors'),
                  ),
                  subtitle: Text(
                    value.quranScript != QuranScriptPreference.uthmaniMadani
                        ? appText(
                            value.language,
                            'উসমানী/মাদানী লিখনরীতিতে তাজবিদের রং পাওয়া যায়।',
                            'Verified Tajweed coloring is available with Uthmani / Madani script.',
                          )
                        : tajweedAvailable
                        ? appText(
                            value.language,
                            'পড়া ও মুখস্থের সময় তাজবিদের নিয়ম রঙে দেখান।',
                            'Color verified Tajweed rules while reading and memorizing.',
                          )
                        : appText(
                            value.language,
                            'তাজবিদের রঙের জন্য কুরআন ডেটা হালনাগাদ করুন।',
                            'Regenerate the verified Quran content package to enable Tajweed colors.',
                          ),
                  ),
                  value:
                      value.showTajweedColors &&
                      tajweedAvailable &&
                      value.quranScript == QuranScriptPreference.uthmaniMadani,
                  onChanged:
                      tajweedAvailable &&
                          value.quranScript ==
                              QuranScriptPreference.uthmaniMadani
                      ? (enabled) => ref
                            .read(appPreferencesControllerProvider.notifier)
                            .setShowTajweedColors(enabled)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-tap-translation-card'),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    appText(
                      value.language,
                      'ট্যাপে অনুবাদ দেখান',
                      'Tap to show translation',
                    ),
                  ),
                  value: value.tapToShowTranslation,
                  onChanged: (enabled) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setTapToShowTranslation(enabled),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-tap-word-card'),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    appText(
                      value.language,
                      'ট্যাপে বাংলা শব্দার্থ দেখান',
                      'Tap to show Bangla word meaning',
                    ),
                  ),
                  value: value.tapToShowBanglaWordMeaning,
                  onChanged: (enabled) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setTapToShowBanglaWordMeaning(enabled),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsSectionHeader(
              icon: Icons.text_fields_rounded,
              title: appText(
                value.language,
                'লেখা ও পড়ার বিন্যাস',
                'Text & Reading Layout',
              ),
              subtitle: appText(
                value.language,
                'পড়ার আকার, ফাঁক ও লাইভ প্রিভিউ',
                'Reading size, spacing and live preview',
              ),
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-typography-preview-card'),
              children: [
                _QuranTypographyPreview(
                  preferences: value,
                  tajweedAvailable: tajweedAvailable,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-reading-scale-card'),
              children: [
                Text(
                  '${appText(value.language, 'আরবি ফন্ট সাইজ', 'Arabic font size')}: ${localDigits('${value.arabicFontSize.round()}', value.language)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                _TransientSlider(
                  min: 20,
                  max: 56,
                  divisions: 36,
                  value: value.arabicFontSize.clamp(20, 56).toDouble(),
                  onPersist: (size) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setArabicFontSize(size),
                ),
                Text(
                  '${appText(value.language, 'আরবি লাইনের ফাঁক', 'Arabic line spacing')}: '
                  '${value.arabicLineHeight.toStringAsFixed(2)}×',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                _TransientSlider(
                  min: AppPreferences.minArabicLineHeight,
                  max: AppPreferences.maxArabicLineHeight,
                  divisions: 13,
                  value: value.arabicLineHeight
                      .clamp(
                        AppPreferences.minArabicLineHeight,
                        AppPreferences.maxArabicLineHeight,
                      )
                      .toDouble(),
                  onPersist: (height) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setArabicLineHeight(height),
                ),
                Text(
                  '${appText(value.language, 'বাংলা লাইনের ফাঁক', 'Bangla line spacing')}: '
                  '${value.banglaLineHeight.toStringAsFixed(2)}×',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                _TransientSlider(
                  min: AppPreferences.minBanglaLineHeight,
                  max: AppPreferences.maxBanglaLineHeight,
                  divisions: 10,
                  value: value.banglaLineHeight
                      .clamp(
                        AppPreferences.minBanglaLineHeight,
                        AppPreferences.maxBanglaLineHeight,
                      )
                      .toDouble(),
                  onPersist: (height) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setBanglaLineHeight(height),
                ),
                Text(
                  '${appText(value.language, 'বাংলা ফন্ট সাইজ', 'Bangla font size')}: '
                  '${localDigits('${value.banglaFontSize.round()}', value.language)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                _TransientSlider(
                  min: AppPreferences.minBanglaFontSize,
                  max: AppPreferences.maxBanglaFontSize,
                  divisions: 16,
                  value: value.banglaFontSize
                      .clamp(
                        AppPreferences.minBanglaFontSize,
                        AppPreferences.maxBanglaFontSize,
                      )
                      .toDouble(),
                  onPersist: (size) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setBanglaFontSize(size),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-show-translation-card'),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    appText(value.language, 'অনুবাদ দেখান', 'Show translation'),
                  ),
                  value: value.showTranslation,
                  onChanged: (enabled) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setShowTranslation(enabled),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-active-word-card'),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    appText(
                      value.language,
                      'অডিও চলার সময় সক্রিয় শব্দ হাইলাইট',
                      'Highlight active word during playback',
                    ),
                  ),
                  subtitle: Text(
                    appText(
                      value.language,
                      'আয়াতের অডিও চলার সময় উচ্চারিত আরবি শব্দটি হাইলাইট হবে।',
                      'Highlights the spoken Arabic word while ayah audio plays.',
                    ),
                  ),
                  value: value.highlightActiveWord,
                  onChanged: (enabled) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setHighlightActiveWord(enabled),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-playback-meaning-card'),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    appText(
                      value.language,
                      'প্লে করার সময় শব্দের বাংলা অর্থ দেখান',
                      'Show Bangla word meaning during playback',
                    ),
                  ),
                  subtitle: Text(
                    appText(
                      value.language,
                      'বর্তমান শব্দের অর্থ ছোট বাবলে দেখাবে; সম্পূর্ণ আয়াতের অনুবাদ অপরিবর্তিত থাকবে।',
                      'Shows the current word meaning in a small bubble; the full ayah translation stays unchanged.',
                    ),
                  ),
                  value: value.showPlaybackBanglaWordMeaning,
                  onChanged: (enabled) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setShowPlaybackBanglaWordMeaning(enabled),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsSectionHeader(
              icon: Icons.graphic_eq_rounded,
              title: appText(
                value.language,
                'অডিও ও তিলাওয়াত',
                'Audio & Recitation',
              ),
              subtitle: appText(
                value.language,
                'পুনরাবৃত্তি, গতি ও কারি',
                'Repeat, speed and reciter',
              ),
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-repeat-card'),
              children: [
                _PlaybackChoiceGroup<int>(
                  label: appText(
                    value.language,
                    'পুনরাবৃত্তির সংখ্যা',
                    'Default repeat',
                  ),
                  values: AppPreferences.supportedRepeatCounts,
                  selected: value.defaultRepeatCount,
                  keyFor: (count) => ValueKey('repeat-choice-$count'),
                  labelFor: (count) => '$count×',
                  onSelected: (count) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setDefaultRepeatCount(count),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-speed-card'),
              children: [
                _PlaybackChoiceGroup<double>(
                  label: appText(value.language, 'অডিওর গতি', 'Playback speed'),
                  values: AppPreferences.supportedPlaybackSpeeds,
                  selected: value.defaultPlaybackSpeed,
                  keyFor: (speed) => ValueKey('speed-choice-$speed'),
                  labelFor: (speed) => '$speed×',
                  onSelected: (speed) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setDefaultPlaybackSpeed(speed),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-repeat-pause-card'),
              children: [
                Text(
                  "${appText(value.language, 'পুনরাবৃত্তির বিরতি', 'Pause between repeats')}: "
                  "${(value.repeatPause.inMilliseconds / 1000).toStringAsFixed(1)} s",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                _TransientSlider(
                  min: 0,
                  max: 5,
                  divisions: 10,
                  value: (value.repeatPause.inMilliseconds / 1000)
                      .clamp(0, 5)
                      .toDouble(),
                  onPersist: (seconds) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setRepeatPause(
                        Duration(milliseconds: (seconds * 1000).round()),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-auto-next-card'),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    appText(
                      value.language,
                      'পরের আয়াত স্বয়ংক্রিয়ভাবে চালান',
                      'Automatically continue to next ayah',
                    ),
                  ),
                  value: value.autoNextAyah,
                  onChanged: (enabled) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setAutoNextAyah(enabled),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SettingsCard(
              key: const ValueKey('settings-reciter-card'),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.record_voice_over_outlined),
                  title: Text(
                    appText(
                      value.language,
                      'কারি ও সূরার অডিও',
                      'Reciters & Surah audio',
                    ),
                  ),
                  subtitle: Text(
                    appText(
                      value.language,
                      'কারি বাছুন এবং সূরা শুনুন বা অফলাইনে নামান।',
                      'Choose a reciter and select any Surah for streaming or offline download.',
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ReciterAudioPage(
                        currentSurahNumber: currentSurahNumber,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Semantics(
      container: true,
      label: '$title. $subtitle',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({
    required this.language,
    required this.selected,
    required this.onSelected,
  });

  final AppLanguage language;
  final AppThemePreference selected;
  final ValueChanged<AppThemePreference> onSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 8.0;
      final width = (constraints.maxWidth - gap) / 2;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final theme in AppThemePreference.values)
            SizedBox(
              width: width,
              child: _ThemeChoice(
                label: _themeLabel(theme, language),
                swatch: _themeSwatch(theme),
                selected: theme == selected,
                onTap: () => onSelected(theme),
              ),
            ),
        ],
      );
    },
  );
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.label,
    required this.swatch,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color swatch;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? colors.primaryContainer.withValues(alpha: 0.45)
            : colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? colors.primary : colors.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: swatch,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.onSurface.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: colors.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _themeLabel(AppThemePreference theme, AppLanguage language) =>
    switch (theme) {
      AppThemePreference.light =>
        language == AppLanguage.bangla ? 'টিল ব্লু' : 'Teal Blue',
      AppThemePreference.green =>
        language == AppLanguage.bangla ? 'সি গ্রিন' : 'Sea Green',
      AppThemePreference.dark =>
        language == AppLanguage.bangla ? 'টারকোয়েজ ডার্ক' : 'Turquoise Dark',
      AppThemePreference.women =>
        language == AppLanguage.bangla ? 'মভ রোজ' : 'Mauve Rose',
    };

Color _themeSwatch(AppThemePreference theme) => switch (theme) {
  AppThemePreference.light => const Color(0xFF27687E),
  AppThemePreference.green => const Color(0xFF397A65),
  AppThemePreference.dark => const Color(0xFF55BBC2),
  AppThemePreference.women => const Color(0xFFA75E7B),
};

class _PlaybackChoiceGroup<T> extends StatelessWidget {
  const _PlaybackChoiceGroup({
    required this.label,
    required this.values,
    required this.selected,
    required this.keyFor,
    required this.labelFor,
    required this.onSelected,
  });

  final String label;
  final List<T> values;
  final T selected;
  final Key Function(T value) keyFor;
  final String Function(T value) labelFor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in values)
              ChoiceChip(
                key: keyFor(item),
                label: Text(labelFor(item)),
                selected: item == selected,
                showCheckmark: false,
                onSelected: (_) => onSelected(item),
              ),
          ],
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _QuranTypographyPreview extends StatelessWidget {
  const _QuranTypographyPreview({
    required this.preferences,
    required this.tajweedAvailable,
  });

  final AppPreferences preferences;
  final bool tajweedAvailable;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final font = preferences.quranFont;
    final script = font.script;
    final sample = BismillahText.plainFor(script);
    final useTajweed =
        preferences.showTajweedColors &&
        tajweedAvailable &&
        script == QuranScriptPreference.uthmaniMadani;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Preview · ${script.label}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          DefaultTextStyle(
            style: QuranTextStyle.forScript(
              script: script,
              color: scheme.onSurface,
              fontSize: preferences.arabicFontSize,
              lineHeight: preferences.arabicLineHeight,
              font: font,
            ),
            child: QuranTajweedText(
              plainText: sample,
              markup: BismillahText.uthmaniTajweedMarkup,
              useTajweedColors: useTajweed,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'পরম করুণাময় ও অসীম দয়ালু আল্লাহর নামে।',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: preferences.banglaLineHeight,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransientSlider extends StatefulWidget {
  const _TransientSlider({
    required this.min,
    required this.max,
    required this.divisions,
    required this.value,
    required this.onPersist,
  });

  final double min;
  final double max;
  final int divisions;
  final double value;
  final ValueChanged<double> onPersist;

  @override
  State<_TransientSlider> createState() => _TransientSliderState();
}

class _TransientSliderState extends State<_TransientSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant _TransientSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: widget.min,
      max: widget.max,
      divisions: widget.divisions,
      value: _value,
      onChanged: (value) => setState(() => _value = value),
      onChangeEnd: widget.onPersist,
    );
  }
}
