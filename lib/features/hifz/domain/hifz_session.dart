import 'hifz_preset.dart';

class AyahRef {
  const AyahRef({required this.surahNumber, required this.ayahNumber});

  final int surahNumber;
  final int ayahNumber;

  String get verseKey => '$surahNumber:$ayahNumber';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AyahRef &&
            surahNumber == other.surahNumber &&
            ayahNumber == other.ayahNumber;
  }

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber);

  @override
  String toString() => verseKey;
}

class HifzSessionConfig {
  const HifzSessionConfig({
    required this.start,
    required this.end,
    required this.preset,
  });

  final AyahRef start;
  final AyahRef end;
  final HifzPreset preset;
}

enum HifzSessionStatus { idle, running, paused, stopped, completed, error }

class HifzSessionCheckpoint {
  const HifzSessionCheckpoint({
    required this.profileKey,
    required this.config,
    required this.nextStepIndex,
    required this.status,
    required this.updatedAt,
  });

  final String profileKey;
  final HifzSessionConfig config;
  final int nextStepIndex;
  final HifzSessionStatus status;
  final DateTime updatedAt;

  HifzSessionCheckpoint copyWith({
    int? nextStepIndex,
    HifzSessionStatus? status,
    DateTime? updatedAt,
  }) {
    return HifzSessionCheckpoint(
      profileKey: profileKey,
      config: config,
      nextStepIndex: nextStepIndex ?? this.nextStepIndex,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
