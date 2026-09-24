import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/application/app_preferences_controller.dart';
import '../../application/quran_providers.dart';
import '../../domain/bismillah_policy.dart';
import '../../domain/bismillah_text.dart';
import '../../domain/quran_script.dart';
import '../quran_text_style.dart';
import 'quran_tajweed_text.dart';

class SurahBismillahHeader extends ConsumerWidget {
  const SurahBismillahHeader({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!shouldShowStandaloneBismillah(surahNumber)) {
      return const SizedBox.shrink();
    }

    final font = ref.watch(quranFontProvider);
    final script = font.script;
    final fontSize = ref.watch(arabicFontSizeProvider);
    final lineHeight = ref.watch(arabicLineHeightProvider);
    final tajweedEnabled = ref.watch(showTajweedColorsProvider);
    final tajweedAvailable =
        ref.watch(tajweedQuranTextAvailableProvider).value ?? false;
    final scheme = Theme.of(context).colorScheme;
    final useTajweed =
        tajweedEnabled &&
        tajweedAvailable &&
        script == QuranScriptPreference.uthmaniMadani;

    return Semantics(
      label: 'Bismillah',
      child: Padding(
        key: ValueKey('surah-bismillah-$surahNumber'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: DefaultTextStyle(
          style: QuranTextStyle.forScript(
            script: script,
            color: scheme.onSurface,
            fontSize: (fontSize * 0.92).clamp(24.0, 48.0).toDouble(),
            lineHeight: lineHeight,
            font: font,
          ),
          textAlign: TextAlign.center,
          child: QuranTajweedText(
            plainText: BismillahText.plainFor(script),
            markup: BismillahText.uthmaniTajweedMarkup,
            useTajweedColors: useTajweed,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
