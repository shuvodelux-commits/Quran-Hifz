import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/hifz_appearance_controller.dart';
import '../domain/hifz_font_preference.dart';

/// Hifz-only typography controls and their live preview.
class HifzAppearanceSheet extends ConsumerStatefulWidget {
  const HifzAppearanceSheet({super.key});

  @override
  ConsumerState<HifzAppearanceSheet> createState() =>
      _HifzAppearanceSheetState();
}

class _HifzAppearanceSheetState extends ConsumerState<HifzAppearanceSheet> {
  late HifzFontPreference _font;
  late double _fontSize;
  late double _lineHeight;
  late bool _autoScrollEnabled;
  late HifzAutoScrollSpeed _autoScrollSpeed;
  var _initializedFromPreferences = false;

  @override
  void initState() {
    super.initState();
    _font = HifzFontPreference.defaultHifz;
    _fontSize = 32;
    _lineHeight = const AppPreferences.defaults().hifzLineHeight;
    _autoScrollEnabled = const AppPreferences.defaults().hifzAutoScrollEnabled;
    _autoScrollSpeed = const AppPreferences.defaults().hifzAutoScrollSpeed;
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(appPreferencesControllerProvider).value;
    if (preferences != null && !_initializedFromPreferences) {
      _font = HifzFontPreference.fromRendererFont(preferences.hifzQuranFont);
      _fontSize = preferences.hifzFontSize;
      _lineHeight = preferences.hifzLineHeight;
      _autoScrollEnabled = preferences.hifzAutoScrollEnabled;
      _autoScrollSpeed = preferences.hifzAutoScrollSpeed;
      _initializedFromPreferences = true;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hifz settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _font.script == QuranScriptPreference.uthmaniMadani
                      ? 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ\nٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ'
                      : 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
                  key: const ValueKey('hifz-appearance-preview'),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: _font.rendererFont.fontFamily,
                    fontSize: _fontSize,
                    height: _lineHeight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<HifzFontPreference>(
              key: ValueKey('hifz-appearance-font-${_font.name}'),
              initialValue: _font,
              decoration: const InputDecoration(labelText: 'Quran font'),
              items: [
                for (final option in HifzFontPreference.values)
                  DropdownMenuItem(value: option, child: Text(option.label)),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _font = value);
                ref
                    .read(hifzAppearanceOverrideProvider.notifier)
                    .setFont(value.rendererFont);
                unawaited(
                  ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setHifzQuranFont(value.rendererFont),
                );
              },
            ),
            const SizedBox(height: 10),
            _SliderControl(
              key: const ValueKey('hifz-appearance-size'),
              label: 'Font size',
              value: _fontSize,
              min: AppPreferences.minHifzFontSize,
              max: AppPreferences.maxHifzFontSize,
              divisions: 36,
              onChanged: (value) {
                setState(() => _fontSize = value);
                ref
                    .read(hifzAppearanceOverrideProvider.notifier)
                    .setFontSize(value);
              },
              onChangeEnd: (value) => ref
                  .read(appPreferencesControllerProvider.notifier)
                  .setHifzFontSize(value),
            ),
            _SliderControl(
              key: const ValueKey('hifz-appearance-spacing'),
              label: 'Line spacing',
              value: _lineHeight,
              min: AppPreferences.minHifzLineHeight,
              max: AppPreferences.maxHifzLineHeight,
              divisions: 24,
              onChanged: (value) {
                setState(() => _lineHeight = value);
                ref
                    .read(hifzAppearanceOverrideProvider.notifier)
                    .setLineHeight(value);
              },
              onChangeEnd: (value) => ref
                  .read(appPreferencesControllerProvider.notifier)
                  .setHifzLineHeight(value),
            ),
            const Divider(height: 28),
            SwitchListTile(
              key: const ValueKey('hifz-auto-scroll-enabled'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto scroll'),
              subtitle: const Text('Move through Quran pages hands-free'),
              value: _autoScrollEnabled,
              onChanged: (value) {
                setState(() => _autoScrollEnabled = value);
                unawaited(
                  ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setHifzAutoScrollEnabled(value),
                );
              },
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<HifzAutoScrollSpeed>(
              key: const ValueKey('hifz-auto-scroll-speed'),
              initialValue: _autoScrollSpeed,
              decoration: const InputDecoration(labelText: 'Auto scroll speed'),
              items: const [
                DropdownMenuItem(
                  value: HifzAutoScrollSpeed.slow,
                  child: Text('Slow'),
                ),
                DropdownMenuItem(
                  value: HifzAutoScrollSpeed.medium,
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: HifzAutoScrollSpeed.fast,
                  child: Text('Fast'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _autoScrollSpeed = value);
                unawaited(
                  ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setHifzAutoScrollSpeed(value),
                );
              },
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                key: const ValueKey('hifz-appearance-reset'),
                onPressed: _reset,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reset() {
    setState(() {
      _font = HifzFontPreference.defaultHifz;
      _fontSize = 32;
      _lineHeight = const AppPreferences.defaults().hifzLineHeight;
      _autoScrollEnabled =
          const AppPreferences.defaults().hifzAutoScrollEnabled;
      _autoScrollSpeed = const AppPreferences.defaults().hifzAutoScrollSpeed;
    });
    final controller = ref.read(appPreferencesControllerProvider.notifier);
    ref.read(hifzAppearanceOverrideProvider.notifier).reset();
    unawaited(
      controller.setHifzQuranFont(HifzFontPreference.defaultHifz.rendererFont),
    );
    unawaited(controller.setHifzFontSize(32));
    unawaited(
      controller.setHifzLineHeight(
        const AppPreferences.defaults().hifzLineHeight,
      ),
    );
    unawaited(
      controller.setHifzAutoScrollEnabled(
        const AppPreferences.defaults().hifzAutoScrollEnabled,
      ),
    );
    unawaited(
      controller.setHifzAutoScrollSpeed(
        const AppPreferences.defaults().hifzAutoScrollSpeed,
      ),
    );
  }
}

class _SliderControl extends StatelessWidget {
  const _SliderControl({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value.toStringAsFixed(2))],
      ),
      Slider(
        value: value.clamp(min, max).toDouble(),
        min: min,
        max: max,
        divisions: divisions,
        label: value.toStringAsFixed(2),
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    ],
  );
}
