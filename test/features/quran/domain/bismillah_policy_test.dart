import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/bismillah_policy.dart';

void main() {
  test('does not duplicate Al-Fatihah Bismillah ayah', () {
    expect(shouldShowStandaloneBismillah(1), isFalse);
  });

  test('shows standalone Bismillah for normal Surahs', () {
    expect(shouldShowStandaloneBismillah(2), isTrue);
    expect(shouldShowStandaloneBismillah(8), isTrue);
    expect(shouldShowStandaloneBismillah(10), isTrue);
    expect(shouldShowStandaloneBismillah(114), isTrue);
  });

  test('At-Tawbah never shows standalone Bismillah', () {
    expect(shouldShowStandaloneBismillah(9), isFalse);
  });

  test('rejects invalid Surah numbers', () {
    expect(() => shouldShowStandaloneBismillah(0), throwsRangeError);
    expect(() => shouldShowStandaloneBismillah(115), throwsRangeError);
  });
}
