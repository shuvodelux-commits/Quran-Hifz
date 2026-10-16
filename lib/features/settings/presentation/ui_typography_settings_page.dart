import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../core/localization/app_locale_text.dart';
import '../application/app_preferences_controller.dart';
import '../domain/app_preferences.dart';

/// A preview-first control for ordinary application text only.
/// Quran Arabic, translations and the Hifz Mushaf keep their own font sliders.
class UiTypographySettingsPage extends ConsumerStatefulWidget {
  const UiTypographySettingsPage({super.key});

  @override
  ConsumerState<UiTypographySettingsPage> createState() =>
      _UiTypographySettingsPageState();
}

class _UiTypographySettingsPageState
    extends ConsumerState<UiTypographySettingsPage> {
  bool _initialized = false;
  bool _saving = false;
  double _fontScale = 1.0;
  double _lineHeightScale = 1.0;
  bool _followSystemTextSize = false;

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(appPreferencesControllerProvider);
    final language = ref.watch(appLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(appText(language, 'ফন্ট সেটিংস', 'Font settings')),
      ),
      body: preferences.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(appText(
            language,
            'ফন্ট সেটিংস পাওয়া যাচ্ছে না।',
            'Font settings are unavailable.',
          )),
        ),
        data: (value) {
          // First load only. User edits stay local until Save is pressed.
          if (!_initialized) {
            _fontScale = value.uiFontScale;
            _lineHeightScale = value.uiLineHeightScale;
            _followSystemTextSize = value.followSystemTextSize;
            _initialized = true;
          }
          return _buildForm(context, value);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, AppPreferences preferences) {
    final language = preferences.language;
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _sliderSetting(
                  label: appText(language, 'ফন্ট সাইজ', 'Font size'),
                  value: _fontScale,
                  min: AppPreferences.minUiFontScale,
                  max: AppPreferences.maxUiFontScale,
                  divisions: 13,
                  key: const ValueKey('ui-font-scale-slider'),
                  onChanged: (value) => setState(() => _fontScale = value),
                ),
                const SizedBox(height: 18),
                _sliderSetting(
                  label: appText(language, 'লাইন হাইট', 'Line height'),
                  value: _lineHeightScale,
                  min: AppPreferences.minUiLineHeightScale,
                  max: AppPreferences.maxUiLineHeightScale,
                  divisions: 12,
                  key: const ValueKey('ui-line-height-slider'),
                  onChanged: (value) =>
                      setState(() => _lineHeightScale = value),
                ),
                const SizedBox(height: 22),
                Text(
                  appText(language, 'লেখার প্রিভিউ', 'Text preview'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Theme(
                  data: appTheme(
                    preferences.theme,
                    language: preferences.language,
                    uiFontScale: _fontScale,
                    uiLineHeightScale: _lineHeightScale,
                  ),
                  child: Builder(builder: (previewContext) {
                    final preview = Theme.of(previewContext);
                    return Container(
                      key: const ValueKey('ui-typography-preview'),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        border: Border.all(color: colors.outlineVariant),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appText(
                              language,
                              'জামাত সহকারে নামাযের ফযীলত',
                              'Read and reflect every day',
                            ),
                            style: preview.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            appText(
                              language,
                              'পড়ার সুবিধার জন্য লেখার আকার ও লাইনের ফাঁক নিজের মতো ঠিক করুন।',
                              'Choose a comfortable text size and line spacing for everyday reading.',
                            ),
                            style: preview.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            appText(
                              language,
                              'এটি ছোট লেখার নমুনা',
                              'This is a smaller label',
                            ),
                            style: preview.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                SwitchListTile.adaptive(
                  key: const ValueKey('ui-follow-system-font'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    appText(
                      language,
                      'ফোনের ফন্ট সাইজ অনুসরণ করুন',
                      'Follow phone text size',
                    ),
                  ),
                  subtitle: Text(
                    appText(
                      language,
                      'চালু করলে ফোনের সেটিংস অনুযায়ী লেখা আরও বড় হতে পারে।',
                      'When enabled, Android text size can enlarge app text.',
                    ),
                  ),
                  value: _followSystemTextSize,
                  onChanged: _saving
                      ? null
                      : (enabled) =>
                          setState(() => _followSystemTextSize = enabled),
                ),
                const SizedBox(height: 8),
                Text(
                  appText(
                    language,
                    'কুরআন, অনুবাদ ও হিফজের লেখার আকার আগের মতো আলাদা থাকবে।',
                    'Quran, translation and Hifz reading sizes remain separate.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: const ValueKey('ui-typography-reset'),
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text(appText(language, 'রিসেট', 'Reset')),
                    onPressed: _saving
                        ? null
                        : () => setState(() {
                            const defaults = AppPreferences.defaults();
                            _fontScale = defaults.uiFontScale;
                            _lineHeightScale = defaults.uiLineHeightScale;
                            _followSystemTextSize =
                                defaults.followSystemTextSize;
                          }),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey('ui-typography-cancel'),
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: Text(appText(language, 'বাতিল', 'Cancel')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('ui-typography-save'),
                    onPressed: _saving ? null : _save,
                    child: Text(
                      appText(language, 'সংরক্ষণ করুন', 'Save'),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Key key,
    required ValueChanged<double> onChanged,
  }) {
    final percent = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text('$percent%', style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        Slider(
          key: key,
          min: min,
          max: max,
          divisions: divisions,
          value: value.clamp(min, max).toDouble(),
          label: '$percent%',
          onChanged: _saving ? null : onChanged,
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(appPreferencesControllerProvider.notifier).setUiTypography(
        fontScale: _fontScale,
        lineHeightScale: _lineHeightScale,
        followSystemTextSize: _followSystemTextSize,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appText(
            ref.read(appLanguageProvider),
            'ফন্ট সেটিংস সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।',
            'Could not save font settings. Please retry.',
          )),
        ),
      );
    }
  }
}
