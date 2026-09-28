import '../../quran/domain/canonical_quran_counts.dart';
import '../domain/hifz_session.dart';
import '../domain/hifz_step.dart';

class HifzSequenceBuilder {
  const HifzSequenceBuilder();

  List<HifzStep> build(HifzSessionConfig config) {
    _validate(config);

    final preset = config.preset;
    if (preset.ayahRepeatCount <= 0 || preset.combinedRepeatCount <= 0) {
      throw ArgumentError('Hifz repeat counts must be positive.');
    }
    if (preset.finalRangeRepeatCount < 0) {
      throw ArgumentError('Final range repeat count cannot be negative.');
    }

    final steps = <HifzStep>[];

    for (
      var ayahNumber = config.start.ayahNumber;
      ayahNumber <= config.end.ayahNumber;
      ayahNumber++
    ) {
      final current = AyahRef(
        surahNumber: config.start.surahNumber,
        ayahNumber: ayahNumber,
      );

      steps.add(
        AyahStep(
          ayah: current,
          repeatCount: preset.ayahRepeatCount,
          pauseBetweenRepeats: preset.pauseBetweenRepeats,
        ),
      );

      if (preset.progressiveCombination &&
          ayahNumber > config.start.ayahNumber) {
        steps.add(
          RangeStep(
            start: config.start,
            end: current,
            repeatCount: preset.combinedRepeatCount,
            pauseBetweenRepeats: preset.pauseBetweenRepeats,
          ),
        );
      }
    }

    if (preset.finalRangeRepeatCount > 0) {
      steps.add(
        RangeStep(
          start: config.start,
          end: config.end,
          repeatCount: preset.finalRangeRepeatCount,
          pauseBetweenRepeats: preset.pauseBetweenRepeats,
          phase: HifzStepPhase.finalReview,
        ),
      );
    }

    return List<HifzStep>.unmodifiable(steps);
  }

  void _validate(HifzSessionConfig config) {
    final start = config.start;
    final end = config.end;

    if (start.surahNumber != end.surahNumber) {
      throw ArgumentError('V1 Hifz ranges must stay inside one Surah.');
    }

    final canonicalAyahCount = canonicalAyahCountForSurah(start.surahNumber);
    if (canonicalAyahCount == null) {
      throw ArgumentError.value(
        start.surahNumber,
        'surahNumber',
        'Surah number must be between 1 and 114.',
      );
    }
    if (start.ayahNumber < 1 || start.ayahNumber > canonicalAyahCount) {
      throw ArgumentError.value(
        start.ayahNumber,
        'startAyahNumber',
        'Ayah must be between 1 and $canonicalAyahCount for Surah ${start.surahNumber}.',
      );
    }
    if (end.ayahNumber < 1 || end.ayahNumber > canonicalAyahCount) {
      throw ArgumentError.value(
        end.ayahNumber,
        'endAyahNumber',
        'Ayah must be between 1 and $canonicalAyahCount for Surah ${end.surahNumber}.',
      );
    }
    if (start.ayahNumber > end.ayahNumber) {
      throw ArgumentError('Hifz range start must not be after the end.');
    }
  }
}
