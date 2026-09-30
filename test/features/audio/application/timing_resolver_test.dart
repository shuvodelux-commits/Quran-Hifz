import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/audio/application/timing_resolver.dart';
import 'package:quran_hifz/features/audio/domain/audio_timing.dart';

void main() {
  const resolver = TimingResolver();
  final segments = [
    WordAudioTiming(
      wordPosition: 1,
      start: Duration(milliseconds: 100),
      end: Duration(milliseconds: 200),
    ),
    WordAudioTiming(
      wordPosition: 2,
      start: Duration(milliseconds: 250),
      end: Duration(milliseconds: 400),
    ),
    WordAudioTiming(
      wordPosition: 3,
      start: Duration(milliseconds: 400),
      end: Duration(milliseconds: 550),
    ),
  ];

  test('returns null before first segment', () {
    expect(
      resolver.activeWordAt(const Duration(milliseconds: 99), segments),
      isNull,
    );
  });

  test('treats segment start as inclusive', () {
    expect(
      resolver.activeWordAt(const Duration(milliseconds: 100), segments),
      1,
    );
  });

  test('resolves a position in the middle of a segment', () {
    expect(
      resolver.activeWordAt(const Duration(milliseconds: 160), segments),
      1,
    );
  });

  test('treats segment end as exclusive and preserves gaps', () {
    expect(
      resolver.activeWordAt(const Duration(milliseconds: 200), segments),
      isNull,
    );
    expect(
      resolver.activeWordAt(const Duration(milliseconds: 225), segments),
      isNull,
    );
  });

  test('exact boundary belongs to the next contiguous segment', () {
    expect(
      resolver.activeWordAt(const Duration(milliseconds: 400), segments),
      3,
    );
  });

  test('returns null after the final segment', () {
    expect(
      resolver.activeWordAt(const Duration(milliseconds: 550), segments),
      isNull,
    );
  });

  test('supports a single segment', () {
    final one = [
      WordAudioTiming(
        wordPosition: 9,
        start: Duration(milliseconds: 5),
        end: Duration(milliseconds: 10),
      ),
    ];
    expect(resolver.activeWordAt(const Duration(milliseconds: 5), one), 9);
    expect(
      resolver.activeWordAt(const Duration(milliseconds: 10), one),
      isNull,
    );
  });

  test('synthesizes fallback word timing across the ayah window', () {
    final generated = resolver.synthesizeWordTimings(
      ayahTiming: AyahAudioTiming(
        start: const Duration(milliseconds: 1000),
        end: const Duration(milliseconds: 4000),
      ),
      wordPositions: const [1, 2, 3],
    );

    expect(generated, hasLength(3));
    expect(generated.first.start, const Duration(milliseconds: 1000));
    expect(generated.last.end, const Duration(milliseconds: 4000));
    expect(
      resolver.activeWordAt(const Duration(milliseconds: 1500), generated),
      1,
    );
    expect(
      resolver.activeWordAt(const Duration(milliseconds: 2500), generated),
      2,
    );
    expect(
      resolver.activeWordAt(const Duration(milliseconds: 3500), generated),
      3,
    );
  });

  test('returns null for missing timing segments', () {
    expect(resolver.activeWordAt(Duration.zero, const []), isNull);
  });
}
