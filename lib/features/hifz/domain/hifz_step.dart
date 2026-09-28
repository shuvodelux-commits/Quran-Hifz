import 'hifz_session.dart';

enum HifzStepPhase { newAyah, cumulativeReview, finalReview }

sealed class HifzStep {
  const HifzStep({
    required this.repeatCount,
    required this.pauseBetweenRepeats,
    required this.phase,
  });

  final int repeatCount;
  final Duration pauseBetweenRepeats;
  final HifzStepPhase phase;
}

class AyahStep extends HifzStep {
  const AyahStep({
    required this.ayah,
    required super.repeatCount,
    required super.pauseBetweenRepeats,
    super.phase = HifzStepPhase.newAyah,
  });

  final AyahRef ayah;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AyahStep &&
            ayah == other.ayah &&
            repeatCount == other.repeatCount &&
            pauseBetweenRepeats == other.pauseBetweenRepeats &&
            phase == other.phase;
  }

  @override
  int get hashCode =>
      Object.hash(ayah, repeatCount, pauseBetweenRepeats, phase);
}

class RangeStep extends HifzStep {
  const RangeStep({
    required this.start,
    required this.end,
    required super.repeatCount,
    required super.pauseBetweenRepeats,
    super.phase = HifzStepPhase.cumulativeReview,
  });

  final AyahRef start;
  final AyahRef end;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RangeStep &&
            start == other.start &&
            end == other.end &&
            repeatCount == other.repeatCount &&
            pauseBetweenRepeats == other.pauseBetweenRepeats &&
            phase == other.phase;
  }

  @override
  int get hashCode =>
      Object.hash(start, end, repeatCount, pauseBetweenRepeats, phase);
}
