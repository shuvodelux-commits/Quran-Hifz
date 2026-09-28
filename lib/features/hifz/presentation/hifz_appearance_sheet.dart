import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../quran/domain/quran_mushaf_variant.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';

class HifzAppearanceSheet extends ConsumerWidget {
  const HifzAppearanceSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences =
        ref.watch(appPreferencesControllerProvider).value ??
        const AppPreferences.defaults();
    final controller = ref.read(appPreferencesControllerProvider.notifier);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Text(
              'Hifz appearance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 18),
            Text('Mushaf skin', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<QuranMushafVariant>(
              segments: [
                for (final variant in QuranMushafVariant.values)
                  ButtonSegment<QuranMushafVariant>(
                    value: variant,
                    label: Text(variant.label),
                  ),
              ],
              selected: {preferences.hifzMushafVariant},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                if (selection.isEmpty) return;
                unawaited(controller.setHifzMushafVariant(selection.first));
              },
            ),
            const SizedBox(height: 22),
            _SliderLabel(
              label: 'Quran size',
              value: preferences.hifzFontSize.toStringAsFixed(0),
            ),
            Slider(
              key: const ValueKey('hifz-font-size-slider'),
              min: AppPreferences.minHifzFontSize,
              max: AppPreferences.maxHifzFontSize,
              divisions: 36,
              value: preferences.hifzFontSize,
              onChanged: (value) {
                unawaited(controller.setHifzFontSize(value));
              },
            ),
            const SizedBox(height: 8),
            _SliderLabel(
              label: 'Line spacing',
              value: preferences.hifzLineHeight.toStringAsFixed(2),
            ),
            Slider(
              key: const ValueKey('hifz-line-height-slider'),
              min: AppPreferences.minHifzLineHeight,
              max: AppPreferences.maxHifzLineHeight,
              divisions: 24,
              value: preferences.hifzLineHeight,
              onChanged: (value) {
                unawaited(controller.setHifzLineHeight(value));
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tajweed colors'),
              subtitle: const Text('Used by the QCF V4 Tajweed skin'),
              value: preferences.hifzShowTajweedColors,
              onChanged: (value) {
                unawaited(controller.setHifzShowTajweedColors(value));
              },
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              key: const ValueKey('hifz-appearance-reset'),
              onPressed: () => unawaited(_reset(controller)),
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Reset Hifz appearance'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reset(AppPreferencesController controller) async {
    await controller.setHifzMushafVariant(QuranMushafVariant.qcfV4Tajweed);
    await controller.setHifzFontSize(32);
    await controller.setHifzLineHeight(1.35);
    await controller.setHifzShowTajweedColors(true);
  }
}

class _SliderLabel extends StatelessWidget {
  const _SliderLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
