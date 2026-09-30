import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/core/localization/app_locale_text.dart';
import 'package:quran_hifz/features/home/application/bangladesh_hijri_date_providers.dart';
import 'package:quran_hifz/features/home/application/mosque_prayer_times_providers.dart';
import 'package:quran_hifz/features/home/data/bangladesh_hijri_date.dart';
import 'package:quran_hifz/features/home/data/bangla_calendar.dart';
import 'package:quran_hifz/features/home/data/mosque_prayer_times_repository.dart';
import 'package:quran_hifz/features/home/data/prayer_schedule.dart';
import 'package:quran_hifz/features/home/presentation/home_dashboard_page.dart';
import 'package:quran_hifz/features/home/presentation/home_page.dart';
import 'package:quran_hifz/features/quran/application/todays_ayah.dart';
import 'package:quran_hifz/features/quran/domain/quran_ayah.dart';
import 'package:quran_hifz/app/app_theme.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets(
    'home top location area prompts setup when no location is saved',
    (tester) async {
      for (final language in [AppLanguage.bangla, AppLanguage.english]) {
        final database = UserDatabase.forTesting(NativeDatabase.memory());
        addTearDown(database.close);
        await tester.pumpWidget(
          ProviderScope(
            key: ValueKey(language),
            overrides: [
              bangladeshHijriDateRepositoryProvider.overrideWithValue(
                _FakeHijriRepository(),
              ),
              userDatabaseProvider.overrideWithValue(database),
              appLanguageProvider.overrideWithValue(language),
              savedPrayerLocationProvider.overrideWith((ref) async => null),
              prayerScheduleProvider.overrideWith(
                (ref) async => throw StateError('No location'),
              ),
            ],
            child: MaterialApp(
              theme: appTheme(AppThemePreference.light, language: language),
              home: const HomeDashboardPage(onMore: _noop),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(
            language == AppLanguage.bangla ? 'লোকেশন সেট করুন' : 'Set location',
          ),
          findsOneWidget,
        );
        expect(find.text('4:35'), findsNothing);
      }
    },
  );

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
          bangladeshHijriDateRepositoryProvider.overrideWithValue(
            _FakeHijriRepository(),
          ),
          userDatabaseProvider.overrideWithValue(database),
          prayerScheduleProvider.overrideWith(
            (ref) async => throw StateError('No location'),
          ),
          todaysAyahProvider.overrideWith((ref) async => ayah),
        ],
        child: const MaterialApp(home: HomeDashboardPage(onMore: _noop)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('আজকের আয়াত'), findsOneWidget);
    expect(find.text('আজকের দোয়া'), findsNothing);
    expect(find.text(ayah.arabicText), findsNothing);
    expect(find.text(ayah.translation!), findsOneWidget);

    await tester.tap(find.text(ayah.translation!));
    await tester.pumpAndSettle();

    expect(find.text(ayah.arabicText), findsOneWidget);
    expect(find.text(ayah.translation!), findsWidgets);
    expect(find.text('তাফসির'), findsOneWidget);
  });

  testWidgets('prayer pager shows centered direction cue and switches hint', (
    tester,
  ) async {
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
          bangladeshHijriDateRepositoryProvider.overrideWithValue(
            _FakeHijriRepository(),
          ),
          userDatabaseProvider.overrideWithValue(database),
          prayerScheduleProvider.overrideWith((ref) async => schedule),
        ],
        child: const MaterialApp(home: HomeDashboardPage(onMore: _noop)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('prayer-card-dots')), findsOneWidget);
    expect(find.text('স্থানীয় মসজিদ'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('prayer-card-direction')));
    await tester.pumpAndSettle();

    expect(find.text('সলাতের সময়'), findsOneWidget);
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
            bangladeshHijriDateRepositoryProvider.overrideWithValue(
              _FakeHijriRepository(),
            ),
            userDatabaseProvider.overrideWithValue(database),
            prayerScheduleProvider.overrideWith(
              (ref) async => throw StateError('No location'),
            ),
          ],
          child: MaterialApp(
            theme: appTheme(preference),
            home: const HomeDashboardPage(onMore: _noop),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      final theme = appTheme(preference);
      expect(scaffold.backgroundColor, theme.colorScheme.surface);
      final hero = tester.widget<Container>(
        find.byKey(const ValueKey('home-date-summary')),
      );
      final decoration = hero.decoration! as BoxDecoration;
      final gradient = decoration.gradient! as LinearGradient;
      expect(
        gradient.colors.first,
        Color.lerp(theme.colorScheme.primary, Colors.black, 0.12),
      );
      expect(
        gradient.colors.last,
        Color.lerp(theme.colorScheme.primary, Colors.black, 0.22),
      );
    }
  });

  testWidgets('English prayer start and end times stay separated at 360px', (
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
          bangladeshHijriDateRepositoryProvider.overrideWithValue(
            _FakeHijriRepository(),
          ),
          userDatabaseProvider.overrideWithValue(database),
          appLanguageProvider.overrideWithValue(AppLanguage.english),
          prayerScheduleProvider.overrideWith((ref) async => schedule),
        ],
        child: MaterialApp(
          theme: appTheme(
            AppThemePreference.light,
            language: AppLanguage.english,
          ),
          home: const HomeDashboardPage(onMore: _noop),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final activePrayer = schedule.currentPrayer(DateTime.now());
    final currentPrayerTitleFinder = find.text(
      activePrayer == null ? 'Prayer break' : 'Current Prayer',
    );
    final currentTitle = tester.widget<Text>(currentPrayerTitleFinder);
    expect(
      find.ancestor(
        of: currentPrayerTitleFinder,
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
    final currentTimeLine = tester.widget<Text>(
      find.textContaining(activePrayer == null ? 'Starts at' : 'Ends at'),
    );
    final countdownLabel = tester.widget<Text>(
      find.text(activePrayer == null ? 'Starts in' : 'Ends in'),
    );
    expect(currentTitle.style?.fontSize, 14);
    expect(currentTitle.style?.fontWeight, FontWeight.w500);
    expect(currentTimeLine.style?.fontSize, 12);
    expect(currentTimeLine.style?.fontWeight, FontWeight.w400);
    expect(countdownLabel.style?.fontSize, 12);
    expect(countdownLabel.style?.fontWeight, FontWeight.w400);

    final gregorianParts = localGregorianDate(
      now,
      AppLanguage.english,
    ).split(' ');
    final compactGregorian = gregorianParts
        .sublist(0, gregorianParts.length - 1)
        .join(' ');
    expect(find.text('3 Rabi al-Thani'), findsOneWidget);
    expect(find.textContaining(compactGregorian), findsOneWidget);

    final start = find.descendant(
      of: find.byKey(const ValueKey('prayer-start-Fajr')),
      matching: find.text('04:35 AM'),
    );
    final end = find.descendant(
      of: find.byKey(const ValueKey('prayer-end-Fajr')),
      matching: find.text('05:51 AM'),
    );
    expect(start, findsOneWidget);
    expect(end, findsOneWidget);
    expect(find.text('Start'), findsNothing);
    expect(find.text('End'), findsNothing);

    final fajrName = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('prayer-row-Fajr')),
        matching: find.text('Fajr'),
      ),
    );
    final fajrStart = tester.widget<Text>(start);
    expect(fajrName.style?.fontSize, 14);
    expect(fajrName.style?.fontWeight, FontWeight.w500);
    expect(fajrStart.style?.fontSize, 14);
    expect(fajrStart.style?.fontWeight, FontWeight.w400);

    await tester.dragUntilVisible(
      find.text('Prohibited prayer times'),
      find.byType(ListView),
      const Offset(0, -260),
    );
    await tester.pumpAndSettle();

    final expectedSurfaceText = appTheme(
      AppThemePreference.light,
      language: AppLanguage.english,
    ).colorScheme.onSurface;
    for (final label in [
      'Prohibited prayer times',
      'Sahari & Iftar',
      'Today’s ayah',
    ]) {
      final finder = find.text(label);
      expect(finder, findsOneWidget);
      expect(
        DefaultTextStyle.of(tester.element(finder)).style.color,
        expectedSurfaceText,
        reason: '$label should use onSurface text on a light panel',
      );
    }
  });

  testWidgets('English local mosque card uses one consistent type hierarchy', (
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
          bangladeshHijriDateRepositoryProvider.overrideWithValue(
            _FakeHijriRepository(),
          ),
          userDatabaseProvider.overrideWithValue(database),
          appLanguageProvider.overrideWithValue(AppLanguage.english),
          prayerScheduleProvider.overrideWith((ref) async => schedule),
        ],
        child: MaterialApp(
          theme: appTheme(
            AppThemePreference.light,
            language: AppLanguage.english,
          ),
          home: const HomeDashboardPage(onMore: _noop),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final pager = find.byKey(const ValueKey('prayer-card-pager'));
    await tester.drag(pager, const Offset(-320, 0));
    await tester.pumpAndSettle();

    final azanHeader = tester.widget<Text>(find.text('Azan').hitTestable());
    final jamaatHeader = tester.widget<Text>(find.text('Jamaat').hitTestable());
    final fajrName = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('mosque-time-Fajr')),
        matching: find.text('Fajr'),
      ),
    );
    final azanTime = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('mosque-azan-Fajr')),
        matching: find.text('04:35 AM'),
      ),
    );

    expect(azanHeader.style?.fontSize, 12);
    expect(azanHeader.style?.fontWeight, FontWeight.w500);
    expect(jamaatHeader.style?.fontSize, 12);
    expect(jamaatHeader.style?.fontWeight, FontWeight.w500);
    expect(fajrName.style?.fontSize, 14);
    expect(fajrName.style?.fontWeight, FontWeight.w500);
    expect(azanTime.style?.fontSize, 14);
    expect(azanTime.style?.fontWeight, FontWeight.w400);
  });

  testWidgets(
    'home separates prayer start and end times without tracker controls',
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
            bangladeshHijriDateRepositoryProvider.overrideWithValue(
              _FakeHijriRepository(),
            ),
            userDatabaseProvider.overrideWithValue(database),
            prayerScheduleProvider.overrideWith((ref) async => schedule),
          ],
          child: const MaterialApp(home: HomeDashboardPage(onMore: _noop)),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('নাটোর, বাংলাদেশ'), findsOneWidget);
      final activePrayer = schedule.currentPrayer(DateTime.now());
      expect(
        find.text(activePrayer == null ? 'এখন সলাতের সময় নয়' : 'বর্তমান সলাত'),
        findsOneWidget,
      );
      expect(
        find.textContaining(activePrayer == null ? 'শুরু হবে' : 'শেষ হবে'),
        findsOneWidget,
      );
      expect(find.text('পরবর্তী সলাত'), findsNothing);
      expect(find.byIcon(Icons.mosque_rounded), findsNothing);
      expect(find.byIcon(Icons.schedule_rounded), findsNothing);
      expect(find.byIcon(Icons.menu_book_rounded), findsNothing);
      final gregorianParts = localGregorianDate(
        now,
        AppLanguage.bangla,
      ).split(' ');
      final compactGregorian = gregorianParts
          .sublist(0, gregorianParts.length - 1)
          .join(' ');
      final banglaParts = banglaCalendarDate(now).split(' ');
      final compactBangla = banglaParts
          .sublist(0, banglaParts.length - 1)
          .join(' ');
      expect(find.text('৩ রবিউস সানি'), findsOneWidget);
      expect(find.textContaining(compactGregorian), findsOneWidget);
      expect(find.text(compactBangla), findsOneWidget);
      final fajrStart = find.descendant(
        of: find.byKey(const ValueKey('prayer-start-Fajr')),
        matching: find.text('০৪:১১'),
      );
      final fajrEnd = find.descendant(
        of: find.byKey(const ValueKey('prayer-end-Fajr')),
        matching: find.text('০৫:৩২'),
      );
      expect(fajrStart, findsOneWidget);
      expect(fajrEnd, findsOneWidget);
      expect(find.text('শুরু'), findsNothing);
      expect(find.text('শেষ'), findsNothing);
      final list = tester.widget<ListView>(find.byType(ListView));
      expect(list.padding, const EdgeInsets.fromLTRB(12, 8, 12, 16));
      expect(
        tester.getSize(find.byKey(const ValueKey('prayer-row-Fajr'))).height,
        inInclusiveRange(45, 47),
      );
      final hero = tester.widget<Container>(
        find.byKey(const ValueKey('home-date-summary')),
      );
      final decoration = hero.decoration! as BoxDecoration;
      expect(decoration.gradient, isNotNull);
      expect(decoration.borderRadius, BorderRadius.circular(18));
      expect(decoration.border, isNotNull);
      final prayerTime = tester.widget<Text>(fajrStart);
      expect(prayerTime.style?.fontSize, greaterThanOrEqualTo(14));
      expect(prayerTime.style?.fontWeight, FontWeight.w600);
      expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNothing);
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
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

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('home-nafl-prayer-times')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('নফল সালাতের সময়'), findsOneWidget);
      expect(find.text('দুহা'), findsOneWidget);
      expect(find.text('জাওয়াল শুরু'), findsOneWidget);
      expect(find.text('আওয়াবিন'), findsOneWidget);
      expect(find.text('তাহাজ্জুদ'), findsOneWidget);
      expect(find.text('সাহরি ও ইফতার'), findsOneWidget);
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
          bangladeshHijriDateRepositoryProvider.overrideWithValue(
            _FakeHijriRepository(),
          ),
          userDatabaseProvider.overrideWithValue(database),
          prayerScheduleProvider.overrideWith((ref) async => schedule),
        ],
        child: const MaterialApp(home: HomeDashboardPage(onMore: _noop)),
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
          bangladeshHijriDateRepositoryProvider.overrideWithValue(
            _FakeHijriRepository(),
          ),
          userDatabaseProvider.overrideWithValue(database),
          prayerScheduleProvider.overrideWith((ref) async => schedule),
        ],
        child: const MaterialApp(home: HomeDashboardPage(onMore: _noop)),
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
          bangladeshHijriDateRepositoryProvider.overrideWithValue(
            _FakeHijriRepository(),
          ),
          userDatabaseProvider.overrideWithValue(database),
          prayerScheduleProvider.overrideWith((ref) async => schedule),
          mosquePrayerTimesProvider.overrideWith((ref) => pending.future),
        ],
        child: const MaterialApp(home: HomeDashboardPage(onMore: _noop)),
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
    expect(find.byKey(const ValueKey('mosque-edit-Fajr')), findsNothing);
    pending.complete({});
    await tester.pumpAndSettle();
  });
}

class _FakeHijriRepository extends BangladeshHijriDateRepository {
  @override
  Future<ResolvedHijriDate> convert(DateTime sourceDate) async =>
      const ResolvedHijriDate(
        day: 3,
        month: 4,
        year: 1448,
        monthName: 'Rabi al-Thani',
        source: HijriDateSource.hjcosa,
      );
}

void _noop() {}
