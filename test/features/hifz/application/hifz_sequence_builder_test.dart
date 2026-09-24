import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/application/hifz_sequence_builder.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_preset.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_session.dart';
import 'package:quran_hifz/features/hifz/domain/hifz_step.dart';

void main() {
  group('HifzSequenceBuilder', () {
    const builder = HifzSequenceBuilder();

    test('builds exact progressive sequence for Al-Mulk 1-3', () {
      const config = HifzSessionConfig(
        start: AyahRef(surahNumber: 67, ayahNumber: 1),
        end: AyahRef(surahNumber: 67, ayahNumber: 3),
        preset: HifzPresets.newMemorization,
      );

      final steps = builder.build(config);

      expect(steps, hasLength(5));
      expect(
        steps[0],
        const AyahStep(
          ayah: AyahRef(surahNumber: 67, ayahNumber: 1),
          repeatCount: 5,
          pauseBetweenRepeats: Duration(seconds: 1),
        ),
      );
      expect(
        steps[1],
        const AyahStep(
          ayah: AyahRef(surahNumber: 67, ayahNumber: 2),
          repeatCount: 5,
          pauseBetweenRepeats: Duration(seconds: 1),
        ),
      );
      expect(
        steps[2],
        const RangeStep(
          start: AyahRef(surahNumber: 67, ayahNumber: 1),
          end: AyahRef(surahNumber: 67, ayahNumber: 2),
          repeatCount: 3,
          pauseBetweenRepeats: Duration(seconds: 1),
        ),
      );
      expect(
        steps[3],
        const AyahStep(
          ayah: AyahRef(surahNumber: 67, ayahNumber: 3),
          repeatCount: 5,
          pauseBetweenRepeats: Duration(seconds: 1),
        ),
      );
      expect(
        steps[4],
        const RangeStep(
          start: AyahRef(surahNumber: 67, ayahNumber: 1),
          end: AyahRef(surahNumber: 67, ayahNumber: 3),
          repeatCount: 3,
          pauseBetweenRepeats: Duration(seconds: 1),
        ),
      );
    });

    test('builds approved 1-5 progressive Hifz pattern with final review', () {
      final preset = HifzPresets.progressive(
        ayahRepeatCount: 5,
        combinedRepeatCount: 3,
        finalRangeRepeatCount: 3,
      );
      final config = HifzSessionConfig(
        start: const AyahRef(surahNumber: 1, ayahNumber: 1),
        end: const AyahRef(surahNumber: 1, ayahNumber: 5),
        preset: preset,
      );

      final steps = builder.build(config);

      expect(steps, hasLength(10));
      expect(
        steps.take(9).map((step) {
          if (step is AyahStep) {
            return '${step.ayah.ayahNumber}x${step.repeatCount}';
          }
          final range = step as RangeStep;
          return '${range.start.ayahNumber}-${range.end.ayahNumber}x${range.repeatCount}';
        }).toList(),
        ['1x5', '2x5', '1-2x3', '3x5', '1-3x3', '4x5', '1-4x3', '5x5', '1-5x3'],
      );
      expect(
        steps.last,
        const RangeStep(
          start: AyahRef(surahNumber: 1, ayahNumber: 1),
          end: AyahRef(surahNumber: 1, ayahNumber: 5),
          repeatCount: 3,
          pauseBetweenRepeats: Duration(seconds: 1),
          phase: HifzStepPhase.finalReview,
        ),
      );
    });

    test('custom progressive preset round-trips through persisted id', () {
      final preset = HifzPresets.progressive(
        ayahRepeatCount: 7,
        combinedRepeatCount: 5,
        finalRangeRepeatCount: 1,
        pauseBetweenRepeats: const Duration(milliseconds: 750),
      );

      final restored = HifzPresets.fromId(preset.id);

      expect(restored.ayahRepeatCount, 7);
      expect(restored.combinedRepeatCount, 5);
      expect(restored.finalRangeRepeatCount, 1);
      expect(restored.pauseBetweenRepeats, const Duration(milliseconds: 750));
    });

    test('single ayah produces only its individual practice step', () {
      const config = HifzSessionConfig(
        start: AyahRef(surahNumber: 67, ayahNumber: 5),
        end: AyahRef(surahNumber: 67, ayahNumber: 5),
        preset: HifzPresets.newMemorization,
      );

      final steps = builder.build(config);

      expect(steps, hasLength(1));
      expect(
        steps.single,
        const AyahStep(
          ayah: AyahRef(surahNumber: 67, ayahNumber: 5),
          repeatCount: 5,
          pauseBetweenRepeats: Duration(seconds: 1),
        ),
      );
    });

    test('rejects reverse ayah range', () {
      const config = HifzSessionConfig(
        start: AyahRef(surahNumber: 67, ayahNumber: 5),
        end: AyahRef(surahNumber: 67, ayahNumber: 3),
        preset: HifzPresets.newMemorization,
      );

      expect(() => builder.build(config), throwsArgumentError);
    });

    test('rejects cross-Surah range in V1', () {
      const config = HifzSessionConfig(
        start: AyahRef(surahNumber: 67, ayahNumber: 30),
        end: AyahRef(surahNumber: 68, ayahNumber: 1),
        preset: HifzPresets.newMemorization,
      );

      expect(() => builder.build(config), throwsArgumentError);
    });

    test('rejects non-positive ayah identifiers', () {
      const config = HifzSessionConfig(
        start: AyahRef(surahNumber: 67, ayahNumber: 0),
        end: AyahRef(surahNumber: 67, ayahNumber: 1),
        preset: HifzPresets.newMemorization,
      );

      expect(() => builder.build(config), throwsArgumentError);
    });

    test('rejects Surah number outside canonical Quran range', () {
      const config = HifzSessionConfig(
        start: AyahRef(surahNumber: 115, ayahNumber: 1),
        end: AyahRef(surahNumber: 115, ayahNumber: 1),
        preset: HifzPresets.newMemorization,
      );

      expect(() => builder.build(config), throwsArgumentError);
    });

    test('rejects ayah beyond canonical Surah ayah count', () {
      const config = HifzSessionConfig(
        start: AyahRef(surahNumber: 1, ayahNumber: 7),
        end: AyahRef(surahNumber: 1, ayahNumber: 8),
        preset: HifzPresets.newMemorization,
      );

      expect(() => builder.build(config), throwsArgumentError);
    });

    test('accepts the last canonical ayah of a Surah', () {
      const config = HifzSessionConfig(
        start: AyahRef(surahNumber: 2, ayahNumber: 286),
        end: AyahRef(surahNumber: 2, ayahNumber: 286),
        preset: HifzPresets.newMemorization,
      );

      final steps = builder.build(config);

      expect(steps, hasLength(1));
      expect(
        steps.single,
        isA<AyahStep>().having(
          (step) => step.ayah,
          'ayah',
          const AyahRef(surahNumber: 2, ayahNumber: 286),
        ),
      );
    });
  });
}
