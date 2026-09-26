import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/app_preferences_controller.dart';
import '../domain/hifz_reading_mode.dart';

class HifzReadingModeSelector extends ConsumerWidget {
  const HifzReadingModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(hifzReadingModeProvider);
    final variant = ref.watch(hifzMushafVariantProvider);
    final controller = ref.read(appPreferencesControllerProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<HifzReadingMode>(
          key: const ValueKey('hifz-reading-mode-selector'),
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: HifzReadingMode.regular,
              label: Text('Regular'),
              icon: Icon(Icons.menu_book_outlined),
            ),
            ButtonSegment(
              value: HifzReadingMode.mushaf,
              label: Text('Mushaf'),
              icon: Icon(Icons.auto_stories_outlined),
            ),
          ],
          selected: <HifzReadingMode>{mode},
          onSelectionChanged: (selection) {
            if (selection.isEmpty) return;
            unawaited(controller.setHifzReadingMode(selection.first));
          },
        ),
        if (mode == HifzReadingMode.mushaf) ...[
          const SizedBox(height: 8),
          DropdownButton<QuranMushafVariant>(
            key: const ValueKey('hifz-mushaf-variant-selector'),
            value: variant,
            isDense: true,
            isExpanded: true,
            items: const [
              DropdownMenuItem(
                value: QuranMushafVariant.qcfV4Tajweed,
                child: Text('QCF V4 Tajweed'),
              ),
              DropdownMenuItem(
                value: QuranMushafVariant.qcfV2,
                child: Text('QCF V2 Madani'),
              ),
            ],
            onChanged: (value) {
              if (value == null || value == variant) return;
              unawaited(controller.setHifzMushafVariant(value));
            },
          ),
        ],
      ],
    );
  }
}
