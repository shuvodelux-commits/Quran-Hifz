import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/home/data/bangladesh_cities.dart';

void main() {
  test('all districts are available and Natore resolves inside Bangladesh', () {
    expect(bangladeshCities.length, 64);
    final natore = bangladeshCityById(
      bangladeshCities.singleWhere((city) => city.name == 'Natore').id,
    );
    expect(natore?.bnName, 'নাটোর');
    expect(natore!.latitude, inInclusiveRange(20.0, 27.0));
    expect(natore.longitude, inInclusiveRange(88.0, 93.0));
    expect(bangladeshCityById('not-a-city'), isNull);
  });
}
