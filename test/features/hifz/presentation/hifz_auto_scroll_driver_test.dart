import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_auto_scroll_driver.dart';

void main() {
  test('maps normalized speed linearly to 8 through 72 px per second', () {
    expect(hifzAutoScrollPixelsPerSecond(0), 8);
    expect(hifzAutoScrollPixelsPerSecond(0.5), 40);
    expect(hifzAutoScrollPixelsPerSecond(1), 72);
  });

  test('rejects invalid normalized speeds', () {
    expect(() => hifzAutoScrollPixelsPerSecond(-0.01), throwsArgumentError);
    expect(() => hifzAutoScrollPixelsPerSecond(1.01), throwsArgumentError);
    expect(
      () => hifzAutoScrollPixelsPerSecond(double.nan),
      throwsArgumentError,
    );
  });

  test('converts frame time into distance and clamps to end', () {
    expect(
      hifzAutoScrollNextOffset(
        currentOffset: 100,
        maxScrollExtent: 500,
        normalizedSpeed: 0.5,
        elapsed: const Duration(milliseconds: 250),
      ),
      110,
    );
    expect(
      hifzAutoScrollNextOffset(
        currentOffset: 498,
        maxScrollExtent: 500,
        normalizedSpeed: 1,
        elapsed: const Duration(seconds: 1),
      ),
      500,
    );
  });
}
