import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/application/app_preferences_controller.dart';
import '../../application/quran_providers.dart';
import '../../domain/bismillah_policy.dart';
import 'bismillah_v4_glyph.dart';

class SurahBismillahHeader extends ConsumerWidget {
  const SurahBismillahHeader({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!shouldShowStandaloneBismillah(surahNumber)) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final arabicFontSize = ref.watch(arabicFontSizeProvider);
    final showTajweedColors = ref.watch(effectiveQuranTajweedColorsProvider);
    final glyphSize = (arabicFontSize * 1.25).clamp(34.0, 44.0).toDouble();

    return Padding(
      key: ValueKey('surah-bismillah-$surahNumber'),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Container(
        key: ValueKey('surah-bismillah-card-$surahNumber'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(11),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: BismillahV4Glyph(
            fontSize: glyphSize,
            useTajweedColors: showTajweedColors,
          ),
        ),
      ),
    );
  }
}
