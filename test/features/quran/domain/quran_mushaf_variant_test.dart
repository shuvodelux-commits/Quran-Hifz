import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';

void main() {
  test('strict Mushaf catalog contains only Quran Foundation QCF variants', () {
    expect(QuranMushafVariant.values, [
      QuranMushafVariant.qcfV2,
      QuranMushafVariant.qcfV4Tajweed,
    ]);
    expect(QuranMushafVariant.qcfV2.mushafId, 1);
    expect(QuranMushafVariant.qcfV4Tajweed.mushafId, 19);
    expect(QuranMushafVariant.qcfV2.pageCount, 604);
    expect(QuranMushafVariant.qcfV4Tajweed.pageCount, 604);
  });


}
