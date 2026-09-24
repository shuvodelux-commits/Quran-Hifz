import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/quran/application/tajweed_markup_parser.dart';
import 'package:quran_hifz/features/quran/domain/bismillah_text.dart';
import 'package:quran_hifz/features/quran/domain/tajweed_segment.dart';

void main() {
  test('colors rule tags used by bundled word data', () {
    final segments = parseTajweedMarkup('<rule class=ham_wasl>ٱ</rule>للَّهِ');
    expect(segments.first.rule, TajweedRule.hamWasl);
    expect(segments.map((segment) => segment.text).join(), 'ٱللَّهِ');
  });
  test('parses Quran Foundation tajweed tags without losing Arabic text', () {
    const markup =
        'بِسْمِ <tajweed class=ham_wasl>ٱ</tajweed>للَّهِ '
        '<tajweed class=madda_normal>ـٰ</tajweed>نِ';

    final segments = parseTajweedMarkup(markup);

    expect(
      segments.map((segment) => segment.text).join(),
      'بِسْمِ ٱللَّهِ ـٰنِ',
    );
    expect(
      segments
          .where((segment) => segment.rule != null)
          .map((segment) => segment.rule),
      [TajweedRule.hamWasl, TajweedRule.maddaNormal],
    );
  });

  test(
    'standalone Bismillah markup resolves to the canonical Uthmani text',
    () {
      final plain = parseTajweedMarkup(
        BismillahText.uthmaniTajweedMarkup,
      ).map((segment) => segment.text).join();

      expect(plain, BismillahText.uthmani);
    },
  );

  test('unknown tajweed classes keep their text as uncolored content', () {
    const markup = '<tajweed class=new_rule>ن</tajweed>';

    final segments = parseTajweedMarkup(markup);

    expect(segments, const [TajweedSegment(text: 'ن')]);
  });

  test('end marker span is omitted from renderable tajweed segments', () {
    const markup = 'الرَّحِيمِ <span class=end>١</span>';

    final segments = parseTajweedMarkup(markup);

    expect(segments.map((segment) => segment.text).join(), 'الرَّحِيمِ ');
  });
}
