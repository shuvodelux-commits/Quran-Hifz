import 'package:quran_hifz/features/home/data/bangladesh_cities.dart';
import 'package:quran_hifz/features/home/data/offline_prayer_calculator.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  const calculator = OfflinePrayerCalculator();
  for (final city in bangladeshCities) {
    final first = calculator.calculate(
      DateTime(2026, 9),
      city,
      AsrSchool.hanafi,
    );
    final today = calculator.calculate(
      DateTime(2026, 9, 17),
      city,
      AsrSchool.hanafi,
    );
    if (first.sunrise.hour == 5 &&
        first.sunrise.minute == 45 &&
        first.sunset.hour == 18 &&
        first.sunset.minute == 23) {
      print(
        '${city.name}: Sep1 ${clock(first.sunrise)}-${clock(first.sunset)} '
        'Sep17 ${clock(today.sunrise)}-${clock(today.sunset)}',
      );
    }
  }
}

String clock(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
