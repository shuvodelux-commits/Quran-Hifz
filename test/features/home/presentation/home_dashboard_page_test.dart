import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/home/application/mosque_prayer_times_providers.dart';
import 'package:quran_hifz/features/home/data/mosque_prayer_times_repository.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';
import 'package:quran_hifz/features/home/data/prayer_tracker_repository.dart';
import 'package:quran_hifz/features/home/presentation/home_dashboard_page.dart';
import 'package:quran_hifz/features/home/presentation/home_page.dart';
import 'package:quran_hifz/features/quran/application/todays_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('home replaces the fixed dua card with today’s ayah', (
    tester,
  ) async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    const ayah = QuranAyah(
      surahNumber: 2,
      ayahNumber: 255,
      arabicText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
      translation: 'আল্লাহ, তিনি ছাড়া কোনো উপাস্য নেই।',
      words: [],
    );
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWithValue(database),
          prayerScheduleProvider.overrideWith(
            (ref) async => throw StateError('No location'),
          ),
          todaysAyahProvider.overrideWith((ref) async => ayah),
        ],
        child: const MaterialApp(
          home: HomeDashboardPage(onMore: _noop, onPrayer: _noop),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('আজকের আয়াত'), findsOneWidget);
    expect(find.text('আজকের দোয়া'), findsNothing);
    expect(find.text(ayah.arabicText), findsOneWidget);
    expect(find.textContaining(ayah.translation!), findsOneWidget);
  });

  testWidgets('home background and date hero follow every selected palette', (
    tester,
  ) async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    for (final preference in [
      AppThemePreference.light,
      AppThemePreference.green,
      AppThemePreference.women,
      AppThemePreference.dark,
    ]) {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userDatabaseProvider.overrideWithValue(database),
            prayerScheduleProvider.overrideWith(
              (ref) async => throw StateError('No location'),
            ),
          ],
          child: MaterialApp(
            theme: appTheme(preference),
            home: const HomeDashboardPage(onMore: _noop, onPrayer: _noop),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(
        scaffold.backgroundColor,
        appTheme(preference).colorScheme.surface,
      );
    }
  });

  testWidgets('English prayer ranges remain fully visible at 360px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime.now();
    final schedule = PrayerSchedule(
      location: 'Natore, Bangladesh',
      latitude: 24.42,
      longitude: 88.99,
      hijriDate: '6 Rabi al-Thani 1448 AH',
      sunrise: DateTime(now.year, now.month, now.day, 5, 51),
      sunset: DateTime(now.year, now.month, now.day, 18, 6),
      times: {
        'Fajr': DateTime(now.year, now.month, now.day, 4, 35),
        'Dhuhr': DateTime(now.year, now.month, now.day, 12),
        'Asr': DateTime(now.year, now.month, now.day, 16, 23),
        'Maghrib': DateTime(now.year, now.month, now.day, 18, 6),
        'Isha': DateTime(now.year, now.month, now.day, 19, 22),
      },
      tomorrowFajr: DateTime(now.year, now.month, now.day + 1, 4, 35),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWithValue(database),
          appLanguageProvider.overrideWithValue(AppLanguage.english),
          prayerScheduleProvider.overrideWith((ref) async => schedule),
        ],
        child: MaterialApp(
          theme: appTheme(
            AppThemePreference.light,
            language: AppLanguage.english,
          ),
          home: const HomeDashboardPage(onMore: _noop, onPrayer: _noop),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final rangeFinder = find.text('04:35–05:51 AM');
    expect(rangeFinder, findsOneWidget);
    final range = tester.widget<Text>(rangeFinder);
    final painter = TextPainter(
      text: TextSpan(text: range.data, style: range.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    expect(painter.width, lessThanOrEqualTo(tester.getSize(rangeFinder).width));
    expect(range.overflow, isNot(TextOverflow.ellipsis));
  });

  testWidgets(
    'home shows prayer windows and tapping a row saves the salat check',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final now = DateTime.now();
      final schedule = PrayerSchedule(
        location: 'Natore, Bangladesh',
        latitude: 24.42,
        longitude: 88.99,
        hijriDate: '3 Rabi al-Thani 1448 AH',
        sunrise: DateTime(now.year, now.month, now.day, 5, 32),
        sunset: DateTime(now.year, now.month, now.day, 18, 36),
        times: {
          'Fajr': DateTime(now.year, now.month, now.day, 4, 11),
          'Dhuhr': DateTime(now.year, now.month, now.day, 12, 4),
          'Asr': DateTime(now.year, now.month, now.day, 15, 48),
          'Maghrib': DateTime(now.year, now.month, now.day, 18, 36),
          'Isha': DateTime(now.year, now.month, now.day, 19, 52),
        },
        tomorrowFajr: DateTime(now.year, now.month, now.day + 1, 4, 11),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userDatabaseProvider.overrideWithValue(database),
            prayerScheduleProvider.overrideWith((ref) async => schedule),
          ],
          child: const MaterialApp(
            home: HomeDashboardPage(onMore: _noop, onPrayer: _noop),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('নাটোর, বাংলাদেশ'), findsOneWidget);
      expect(find.text('পরবর্তী সলাত'), findsOneWidget);
      expect(find.textContaining('০৪:১১ – ০৫:৩২'), findsOneWidget);
      final list = tester.widget<ListView>(find.byType(ListView));
      expect(list.padding, const EdgeInsets.fromLTRB(12, 8, 12, 16));
      expect(
        tester.getSize(find.byKey(const ValueKey('prayer-row-Fajr'))).height,
        inInclusiveRange(38, 42),
      );
      final hero = tester.widget<Container>(
        find.byKey(const ValueKey('home-date-summary')),
      );
      final decoration = hero.decoration! as BoxDecoration;
      expect(decoration.gradient, isNull);
      expect(decoration.borderRadius, BorderRadius.circular(12));
      final prayerTime = tester.widget<Text>(
        find.textContaining('০৪:১১ – ০৫:৩২'),
      );
      expect(prayerTime.style?.fontSize, greaterThanOrEqualTo(14));
      expect(prayerTime.style?.fontWeight, FontWeight.w500);
      await tester.tap(find.text('ফজর').last);
      await tester.pumpAndSettle();
      final key =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      expect(
        await PrayerTrackerRepository(database).load(key),
        contains('Fajr'),
      );
      await tester.dragUntilVisible(
        find.text('সলাতের নিষিদ্ধ সময়'),
        find.byType(ListView),
        const Offset(0, -250),
      );
      expect(find.text('সকাল'), findsOneWidget);
      expect(find.text('দুপুর'), findsOneWidget);
      expect(find.text('সন্ধ্যা'), findsOneWidget);
      expect(find.byTooltip('নিষিদ্ধ সময়ের তথ্য'), findsOneWidget);
      expect(find.textContaining('আনুমানিক'), findsNothing);
      await tester.tap(find.byTooltip('নিষিদ্ধ সময়ের তথ্য'));
      await tester.pumpAndSettle();
      expect(find.textContaining('আনুমানিক'), findsOneWidget);
      await tester.tap(find.text('ঠিক আছে'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('swiping the compact prayer card reveals mosque time columns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime.now();
    final schedule = PrayerSchedule(
      location: 'Natore, Bangladesh',
      latitude: 24.42,
      longitude: 88.99,
      hijriDate: '3 Rabi al-Thani 1448 AH',
      sunrise: DateTime(now.year, now.month, now.day, 5, 32),
      sunset: DateTime(now.year, now.month, now.day, 18, 36),
      times: {
        'Fajr': DateTime(now.year, now.month, now.day, 4, 11),
        'Dhuhr': DateTime(now.year, now.month, now.day, 12, 4),
        'Asr': DateTime(now.year, now.month, now.day, 15, 48),
        'Maghrib': DateTime(now.year, now.month, now.day, 18, 36),
        'Isha': DateTime(now.year, now.month, now.day, 19, 52),
      },
      tomorrowFajr: DateTime(now.year, now.month, now.day + 1, 4, 11),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWithValue(database),
          prayerScheduleProvider.overrideWith((ref) async => schedule),
        ],
        child: const MaterialApp(
          home: HomeDashboardPage(onMore: _noop, onPrayer: _noop),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final pager = find.byKey(const ValueKey('prayer-card-pager'));
    expect(pager, findsOneWidget);
    expect(tester.getSize(pager).height, lessThan(300));

    await tester.drag(pager, const Offset(-320, 0));
    await tester.pumpAndSettle();

    expect(find.text('আজান').hitTestable(), findsOneWidget);
    expect(find.text('জামাত').hitTestable(), findsOneWidget);
    expect(find.text('সলাত').hitTestable(), findsOneWidget);
    expect(find.text('জুমু‘আহ').hitTestable(), findsOneWidget);
    expect(find.byKey(const ValueKey('mosque-time-Juma')), findsOneWidget);
    expect(find.byKey(const ValueKey('mosque-time-Sunrise')), findsNothing);
    expect(find.byKey(const ValueKey('mosque-azan-Fajr')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('mosque-azan-Fajr')),
        matching: find.text('০৪:১১'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('editing mosque fields saves selected Azan and Jamaat times', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime.now();
    final schedule = PrayerSchedule(
      location: 'Natore, Bangladesh',
      latitude: 24.42,
      longitude: 88.99,
      hijriDate: '3 Rabi al-Thani 1448 AH',
      sunrise: DateTime(now.year, now.month, now.day, 5, 32),
      sunset: DateTime(now.year, now.month, now.day, 18, 36),
      times: {
        'Fajr': DateTime(now.year, now.month, now.day, 4, 11),
        'Dhuhr': DateTime(now.year, now.month, now.day, 12, 4),
        'Asr': DateTime(now.year, now.month, now.day, 15, 48),
        'Maghrib': DateTime(now.year, now.month, now.day, 18, 36),
        'Isha': DateTime(now.year, now.month, now.day, 19, 52),
      },
      tomorrowFajr: DateTime(now.year, now.month, now.day + 1, 4, 11),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWithValue(database),
          prayerScheduleProvider.overrideWith((ref) async => schedule),
        ],
        child: const MaterialApp(
          home: HomeDashboardPage(onMore: _noop, onPrayer: _noop),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final pager = find.byKey(const ValueKey('prayer-card-pager'));
    await tester.drag(pager, const Offset(-320, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('mosque-azan-Fajr')));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    expect(
      Localizations.localeOf(tester.element(find.byType(TimePickerDialog))),
      const Locale('bn'),
    );
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    final inputs = find.byType(TextField);
    await tester.enterText(inputs.at(0), '5');
    await tester.enterText(inputs.at(1), '07');
    await tester.tap(find.byType(TextButton).last);
    await tester.pumpAndSettle();

    var saved = await MosquePrayerTimesRepository(database).load();
    expect(saved['Fajr']?.azanMinutes, 307);

    await tester.tap(find.byKey(const ValueKey('mosque-jamaat-Fajr')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '12');
    await tester.enterText(find.byType(TextField).at(1), '30');
    await tester.tap(find.byType(TextButton).last);
    await tester.pumpAndSettle();

    saved = await MosquePrayerTimesRepository(database).load();
    expect(saved['Fajr']?.azanMinutes, 307);
    expect(saved['Fajr']?.jamaatMinutes, 750);
  });

  testWidgets('mosque time controls stay disabled until saved times load', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final pending = Completer<Map<String, MosquePrayerTime>>();
    final now = DateTime.now();
    final schedule = PrayerSchedule(
      location: 'Natore, Bangladesh',
      latitude: 24.42,
      longitude: 88.99,
      hijriDate: '3 Rabi al-Thani 1448 AH',
      sunrise: DateTime(now.year, now.month, now.day, 5, 32),
      sunset: DateTime(now.year, now.month, now.day, 18, 36),
      times: {
        'Fajr': DateTime(now.year, now.month, now.day, 4, 11),
        'Dhuhr': DateTime(now.year, now.month, now.day, 12, 4),
        'Asr': DateTime(now.year, now.month, now.day, 15, 48),
        'Maghrib': DateTime(now.year, now.month, now.day, 18, 36),
        'Isha': DateTime(now.year, now.month, now.day, 19, 52),
      },
      tomorrowFajr: DateTime(now.year, now.month, now.day + 1, 4, 11),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWithValue(database),
          prayerScheduleProvider.overrideWith((ref) async => schedule),
          mosquePrayerTimesProvider.overrideWith((ref) => pending.future),
        ],
        child: const MaterialApp(
          home: HomeDashboardPage(onMore: _noop, onPrayer: _noop),
        ),
      ),
    );
    await tester.pump();
    final pager = find.byKey(const ValueKey('prayer-card-pager'));
    await tester.drag(pager, const Offset(-320, 0));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<InkWell>(find.byKey(const ValueKey('mosque-azan-Fajr')))
          .onTap,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('mosque-edit-Fajr')))
          .onPressed,
      isNull,
    );
    pending.complete({});
    await tester.pumpAndSettle();
  });
}

void _noop() {}
