import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/app_preferences_controller.dart';
import '../domain/hifz_reading_mode.dart';

class HifzMushafAppearanceSheet extends ConsumerWidget {
  const HifzMushafAppearanceSheet({super.key});

  static const _common = <HifzMushafPalette>[
    HifzMushafPalette.light,
    HifzMushafPalette.sepia,
    HifzMushafPalette.dark,
    HifzMushafPalette.black,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = ref.watch(hifzMushafVariantProvider);
    final selected = ref.watch(effectiveHifzMushafPaletteProvider);
    final options = variant == QuranMushafVariant.qcfV4Tajweed
        ? HifzMushafPalette.values
        : _common;

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
              'Mushaf appearance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              variant == QuranMushafVariant.qcfV4Tajweed
                  ? 'QPC V4 Tajweed (Preview)'
                  : 'Digital Khatt V2',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final palette in options)
                  ChoiceChip(
                    key: ValueKey('hifz-mushaf-palette-${palette.name}'),
                    label: Text(_label(palette)),
                    selected: selected == palette,
                    onSelected: (isSelected) {
                      if (!isSelected) return;
                      unawaited(
                        ref
                            .read(appPreferencesControllerProvider.notifier)
                            .setHifzMushafPalette(palette),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _label(HifzMushafPalette palette) {
    return switch (palette) {
      HifzMushafPalette.light => 'Light',
      HifzMushafPalette.sepia => 'Sepia',
      HifzMushafPalette.dark => 'Dark',
      HifzMushafPalette.black => 'Black',
      HifzMushafPalette.p1 => 'P1',
      HifzMushafPalette.p2 => 'P2',
      HifzMushafPalette.p3 => 'P3',
      HifzMushafPalette.p4 => 'P4',
      HifzMushafPalette.p5 => 'P5',
      HifzMushafPalette.p6 => 'P6',
    };
  }
}
