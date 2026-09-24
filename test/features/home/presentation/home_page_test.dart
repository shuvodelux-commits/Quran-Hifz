import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';
import 'package:quran_hifz/features/home/presentation/home_page.dart';

void main() {
  testWidgets('home keeps the five prayers and requested shortcuts readable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final schedule = PrayerSchedule(
      location: 'Dhaka, Bangladesh',
      latitude: 23.81,
      longitude: 90.41,
      hijriDate: '3 Rabi al-Thani 1448 AH',
      sunrise: DateTime(now.year, now.month, now.day, 5, 44),
      sunset: DateTime(now.year, now.month, now.day, 18, 3),
      times: {
        'Fajr': DateTime(now.year, now.month, now.day, 4, 28),
        'Dhuhr': DateTime(now.year, now.month, now.day, 11, 54),
        'Asr': DateTime(now.year, now.month, now.day, 16, 20),
        'Maghrib': DateTime(now.year, now.month, now.day, 18, 3),
        'Isha': DateTime(now.year, now.month, now.day, 19, 19),
      },
      tomorrowFajr: DateTime(now.year, now.month, now.day + 1, 4, 28),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prayerScheduleProvider.overrideWith((ref) async => schedule),
        ],
        child: MaterialApp(home: HomePage(onSettings: () {})),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dhaka, Bangladesh'), findsOneWidget);
    expect(find.text('Next prayer'), findsOneWidget);
    for (final name in prayerNames) {
      expect(find.text(name), findsWidgets);
    }
    expect(find.text('ক্যালেন্ডার'), findsOneWidget);
    expect(find.text('কিবলা'), findsOneWidget);
    expect(find.text('নিকটস্থ মসজিদ'), findsNothing);
    expect(find.text('আরও'), findsOneWidget);
    expect(find.text('Tracker'), findsNothing);
    expect(find.text('Tafsir'), findsNothing);
    expect(find.text('99 Names'), findsNothing);
  });
}
