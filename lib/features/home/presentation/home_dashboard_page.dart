import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../quran/application/todays_ayah.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/bangladesh_hijri_date_providers.dart';
import '../application/mosque_prayer_times_providers.dart';
import '../data/bangla_calendar.dart';
import '../data/bangladesh_hijri_date.dart';
import '../data/bangladesh_cities.dart';
import '../data/mosque_prayer_times_repository.dart';
import '../data/prayer_schedule.dart';
import 'home_page.dart'
    show prayerScheduleProvider, savedPrayerLocationProvider;
import 'prayer_location_page.dart';

class HomeDashboardPage extends ConsumerStatefulWidget {
  const HomeDashboardPage({super.key, required this.onMore});
  final VoidCallback onMore;

  @override
  ConsumerState<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends ConsumerState<HomeDashboardPage> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final next = DateTime.now();
      if (_dateKey(next) != _dateKey(_now)) {
        ref.invalidate(prayerScheduleProvider);
        ref.invalidate(todaysAyahProvider);
      }
      setState(() => _now = next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerState = ref.watch(prayerScheduleProvider);
    final language = ref.watch(appLanguageProvider);
    final schedule = prayerState.value;
    final savedLocation = ref.watch(savedPrayerLocationProvider).value;
    final prayerCityId = ref.watch(prayerCityIdProvider);
    final hasConfiguredLocation = prayerCityId != null || savedLocation != null;
    final mosqueTimesState = ref.watch(mosquePrayerTimesProvider);
    final mosqueTimes = mosqueTimesState.value ?? {};
    final mosqueTimesReady = mosqueTimesState.hasValue;
    final current = schedule?.currentPrayer(_now);
    final next = schedule?.nextPrayer(_now);
    final todaysAyah = ref.watch(todaysAyahProvider).value;
    final hijriBoundary = ref.watch(hijriDayBoundaryProvider);
    final baselineHijriSource = BangladeshHijriDateResolver.sourceDate(
      now: _now,
      maghrib: schedule?.times['Maghrib'],
      boundary: hijriBoundary,
      correction: 0,
    );
    final resolvedHijri = ref
        .watch(currentBangladeshHijriDateProvider(baselineHijriSource))
        .value;
    final hijriDate = resolvedHijri?.text ?? schedule?.hijriDateAt(_now) ?? '—';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(prayerScheduleProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'More',
                    onPressed: widget.onMore,
                    icon: Icon(
                      Icons.menu_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const PrayerLocationPage(),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 17,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  _localizedLocation(
                                        schedule?.location,
                                        language,
                                      ) ??
                                      (hasConfiguredLocation
                                          ? appText(
                                              language,
                                              'অবস্থান',
                                              'Location',
                                            )
                                          : appText(
                                              language,
                                              'লোকেশন সেট করুন',
                                              'Set location',
                                            )),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            !hasConfiguredLocation
                                ? appText(
                                    language,
                                    'সঠিক সালাতের সময় দেখতে লোকেশন সেট করুন',
                                    'Set your location for accurate prayer times',
                                  )
                                : schedule == null
                                ? appText(
                                    language,
                                    'আপনার এলাকার সলাতের সময়',
                                    'Prayer times for your location',
                                  )
                                : '${appText(language, 'কিবলা', 'Qibla')}: ${localDigits('${_qibla(schedule.latitude, schedule.longitude).round()}', language)}°',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh prayer times',
                    onPressed: () => ref.invalidate(prayerScheduleProvider),
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _DateHero(
                now: _now,
                schedule: schedule,
                hijriDate: hijriDate,
                language: language,
              ),
              const SizedBox(height: 8),
              _CurrentPrayerCard(
                current: current,
                next: next,
                now: _now,
                language: language,
              ),
              const SizedBox(height: 8),
              SizedBox(
                key: const ValueKey('prayer-card-pager'),
                height: 298,
                child: PageView(
                  children: [
                    _Panel(
                      child: Column(
                        children: [
                          for (final name in [
                            'Fajr',
                            'Sunrise',
                            'Dhuhr',
                            'Asr',
                            'Maghrib',
                            'Isha',
                          ])
                            _PrayerRow(
                              name: name,
                              time: name == 'Sunrise'
                                  ? schedule?.sunrise
                                  : schedule?.times[name],
                              end: switch (name) {
                                'Fajr' => schedule?.sunrise,
                                'Dhuhr' => schedule?.times['Asr'],
                                'Asr' => schedule?.times['Maghrib'],
                                'Maghrib' => schedule?.times['Isha'],
                                'Isha' => schedule?.tomorrowFajr,
                                _ => null,
                              },
                              active: current?.name == name,
                              language: language,
                            ),
                        ],
                      ),
                    ),
                    _Panel(
                      child: Column(
                        children: [
                          _MosqueTimesHeader(language: language),
                          for (final name in mosquePrayerNames)
                            _MosquePrayerRow(
                              name: name,
                              calculatedAzan: schedule?.times[name],
                              savedTime: mosqueTimes[name],
                              active: current?.name == name,
                              language: language,
                              onAzanTap: mosqueTimesReady
                                  ? () => _editMosqueTime(
                                      name,
                                      mosqueTimes[name],
                                      schedule?.times[name],
                                      editAzan: true,
                                    )
                                  : null,
                              onJamaatTap: mosqueTimesReady
                                  ? () => _editMosqueTime(
                                      name,
                                      mosqueTimes[name],
                                      schedule?.times[name],
                                      editAzan: false,
                                    )
                                  : null,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (prayerState.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    prayerState.error is StateError
                        ? (prayerState.error as StateError).message
                        : 'Location and internet access are needed for prayer times.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  language == AppLanguage.bangla
                                      ? 'সলাতের নিষিদ্ধ সময়'
                                      : 'Prohibited prayer times',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: appText(
                                  language,
                                  'নিষিদ্ধ সময়ের তথ্য',
                                  'About prohibited times',
                                ),
                                visualDensity: VisualDensity.compact,
                                onPressed: () =>
                                    _showProhibitedTimesInfo(context, language),
                                icon: const Icon(Icons.info_outline_rounded),
                              ),
                            ],
                          ),
                          const Divider(height: 10),
                          _ProhibitedTimeRow(
                            label: appText(language, 'সকাল', 'Morning'),
                            value: _range(
                              schedule?.sunrise,
                              15,
                              language,
                              after: true,
                            ),
                          ),
                          _ProhibitedTimeRow(
                            label: appText(language, 'দুপুর', 'Noon'),
                            value: _range(
                              schedule?.times['Dhuhr'],
                              5,
                              language,
                            ),
                          ),
                          _ProhibitedTimeRow(
                            label: appText(language, 'সন্ধ্যা', 'Evening'),
                            value: _range(schedule?.sunset, 15, language),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.nights_stay_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  language == AppLanguage.bangla
                                      ? 'আজকের রোজা'
                                      : 'Fasting today',
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            appText(language, 'সেহরি শেষ', 'Suhur ends'),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            localClock(schedule?.times['Fajr'], language),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Divider(height: 14),
                          Text(
                            appText(language, 'ইফতার', 'Iftar'),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            localClock(schedule?.times['Maghrib'], language),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _Panel(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language == AppLanguage.bangla
                                ? 'আজকের আয়াত'
                                : 'Today’s ayah',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            todaysAyah?.arabicText ?? '…',
                            style: TextStyle(fontSize: 21),
                          ),
                          Text(
                            todaysAyah == null
                                ? appText(
                                    language,
                                    'আয়াত লোড হচ্ছে…',
                                    'Loading ayah…',
                                  )
                                : '${todaysAyah.translation ?? ''} · ${appText(language, 'সূরা', 'Surah')} ${localDigits('${todaysAyah.surahNumber}:${todaysAyah.ayahNumber}', language)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editMosqueTime(
    String prayer,
    MosquePrayerTime? saved,
    DateTime? calculatedAzan, {
    required bool editAzan,
  }) async {
    final repository = ref.read(mosquePrayerTimesRepositoryProvider);
    final language = ref.read(appLanguageProvider);
    final fallback = editAzan
        ? saved?.azanMinutes ??
              (calculatedAzan == null
                  ? null
                  : calculatedAzan.hour * 60 + calculatedAzan.minute)
        : saved?.jamaatMinutes;
    final initialMinutes = fallback ?? 12 * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: initialMinutes ~/ 60,
        minute: initialMinutes % 60,
      ),
      builder: language == AppLanguage.bangla
          ? (pickerContext, child) => Localizations.override(
              context: pickerContext,
              locale: const Locale('bn'),
              delegates: GlobalMaterialLocalizations.delegates,
              child: child,
            )
          : null,
    );
    if (picked == null || !mounted) return;
    final minutes = picked.hour * 60 + picked.minute;
    if (editAzan) {
      await repository.saveAzan(prayer, minutes);
    } else {
      await repository.saveJamaat(prayer, minutes);
    }
    if (mounted) ref.invalidate(mosquePrayerTimesProvider);
  }

  Future<void> _showProhibitedTimesInfo(
    BuildContext context,
    AppLanguage language,
  ) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          appText(language, 'নিষিদ্ধ সময় সম্পর্কে', 'About prohibited times'),
        ),
        content: Text(
          appText(
            language,
            'সময়গুলো আনুমানিক। আপনার স্থানীয় মসজিদের সময় অনুসরণ করুন।',
            'These times are approximate. Follow your local mosque timetable.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(appText(language, 'ঠিক আছে', 'OK')),
          ),
        ],
      ),
    );
  }
}

class _DateHero extends StatelessWidget {
  const _DateHero({
    required this.now,
    required this.schedule,
    required this.hijriDate,
    required this.language,
  });
  final DateTime now;
  final PrayerSchedule? schedule;
  final String hijriDate;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cardStart = Color.lerp(scheme.primary, Colors.black, 0.12)!;
    final cardEnd = Color.lerp(scheme.primary, Colors.black, 0.22)!;

    return Container(
      key: const ValueKey('home-date-summary'),
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [cardStart, cardEnd],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.onPrimary.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 520;
          return Row(
            children: [
              Expanded(
                flex: wide ? 7 : 6,
                child: _ReferenceDateBlock(
                  now: now,
                  hijriDate: hijriDate,
                  language: language,
                  wide: wide,
                ),
              ),
              _ReferenceDivider(height: wide ? 82 : 78),
              SizedBox(width: wide ? 18 : 12),
              Expanded(
                flex: wide ? 6 : 5,
                child: Row(
                  children: [
                    Expanded(
                      child: _ReferenceSunStat(
                        label: appText(language, 'সূর্যোদয়', 'Sunrise'),
                        time: schedule?.sunrise,
                        language: language,
                        wide: wide,
                      ),
                    ),
                    SizedBox(width: wide ? 14 : 9),
                    _ReferenceDivider(height: wide ? 64 : 56),
                    SizedBox(width: wide ? 14 : 9),
                    Expanded(
                      child: _ReferenceSunStat(
                        label: appText(language, 'সূর্যাস্ত', 'Sunset'),
                        time: schedule?.sunset,
                        language: language,
                        wide: wide,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReferenceDateBlock extends StatelessWidget {
  const _ReferenceDateBlock({
    required this.now,
    required this.hijriDate,
    required this.language,
    required this.wide,
  });
  final DateTime now;
  final String hijriDate;
  final AppLanguage language;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primaryText = scheme.onPrimary;
    final secondaryText = scheme.onPrimary.withValues(alpha: 0.76);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _compactHijriDate(hijriDate, language),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: primaryText,
            fontSize: wide ? 16 : 14,
            height: 1.15,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: wide ? 7 : 5),
        Text(
          '${_homeWeekday(now, language)} - ${_compactGregorianDate(now, language)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: secondaryText,
            fontSize: wide ? 16 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: wide ? 7 : 5),
        Text(
          _compactBanglaDate(now, language),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: primaryText,
            fontSize: wide ? 16 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ReferenceDivider extends StatelessWidget {
  const _ReferenceDivider({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: height,
    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.18),
  );
}

class _ReferenceSunStat extends StatelessWidget {
  const _ReferenceSunStat({
    required this.label,
    required this.time,
    required this.language,
    this.wide = false,
  });
  final String label;
  final DateTime? time;
  final AppLanguage language;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            localClock(time, language),
            maxLines: 1,
            style: TextStyle(
              color: scheme.onPrimary,
              fontSize: wide ? 22 : 17,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: wide ? 7 : 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: scheme.onPrimary.withValues(alpha: 0.76),
              fontSize: wide ? 15 : 12,
              height: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

String _compactHijriDate(String value, AppLanguage language) {
  if (value == '—') return value;
  final withoutYear = value.replaceFirst(RegExp(r'\s+\d+\s*AH\s*$'), '').trim();
  return localHijriDate(withoutYear, language);
}

String _compactGregorianDate(DateTime value, AppLanguage language) {
  final full = localGregorianDate(value, language);
  final parts = full.split(RegExp(r'\s+'));
  if (parts.length < 3) return full;
  return parts.sublist(0, parts.length - 1).join(' ');
}

String _compactBanglaDate(DateTime value, AppLanguage language) {
  final full = banglaCalendarDate(
    value,
    english: language == AppLanguage.english,
  );
  final parts = full.split(RegExp(r'\s+'));
  if (parts.length < 3) return full;
  return parts.sublist(0, parts.length - 1).join(' ');
}

String _homeWeekday(DateTime value, AppLanguage language) {
  const banglaDays = [
    'সোমবার',
    'মঙ্গলবার',
    'বুধবার',
    'বৃহস্পতিবার',
    'শুক্রবার',
    'শনিবার',
    'রবিবার',
  ];
  const englishDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return language == AppLanguage.bangla
      ? banglaDays[value.weekday - 1]
      : englishDays[value.weekday - 1];
}

class _CurrentPrayerCard extends StatelessWidget {
  const _CurrentPrayerCard({
    required this.current,
    required this.next,
    required this.now,
    required this.language,
  });
  final ({String name, DateTime end})? current;
  final ({String name, DateTime time})? next;
  final DateTime now;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final hasCurrent = current != null;
    final targetTime = hasCurrent ? current!.end : next?.time;
    final remaining = targetTime?.difference(now);
    final title = hasCurrent
        ? appText(language, 'বর্তমান সলাত', 'Current Prayer')
        : appText(language, 'এখন সলাতের সময় নয়', 'Prayer break');
    final name = hasCurrent
        ? localPrayerName(current!.name, language)
        : next == null
        ? '—'
        : '${appText(language, 'পরবর্তী', 'Next')}: ${localPrayerName(next!.name, language)}';
    final timeLabel = hasCurrent
        ? appText(language, 'শেষ হবে', 'Ends at')
        : appText(language, 'শুরু হবে', 'Starts at');
    final countdownLabel = hasCurrent
        ? appText(language, 'শেষ হতে বাকি', 'Ends in')
        : appText(language, 'শুরু হতে বাকি', 'Starts in');

    return _Panel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: language == AppLanguage.english ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: language == AppLanguage.english
                        ? FontWeight.w500
                        : FontWeight.w600,
                  ),
                ),
                Text(
                  '$timeLabel ${localClock(targetTime, language)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: language == AppLanguage.english ? 12 : 13,
                    fontWeight: language == AppLanguage.english
                        ? FontWeight.w400
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                countdownLabel,
                style: TextStyle(
                  fontSize: language == AppLanguage.english ? 12 : 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                remaining == null ? '—' : localCountdown(remaining, language),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: language == AppLanguage.english ? 16 : 17,
                  fontWeight: language == AppLanguage.english
                      ? FontWeight.w500
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.name,
    required this.time,
    this.end,
    required this.active,
    required this.language,
  });
  final String name;
  final DateTime? time;
  final DateTime? end;
  final bool active;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = active ? scheme.primary : scheme.onSurface;
    final muted = active ? scheme.primary : scheme.onSurfaceVariant;

    return Container(
      key: ValueKey('prayer-row-$name'),
      constraints: const BoxConstraints(minHeight: 46, maxHeight: 46),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
        color: active ? scheme.primaryContainer.withValues(alpha: 0.5) : null,
      ),
      child: Row(
        children: [
          Icon(
            name == 'Isha'
                ? Icons.nights_stay_outlined
                : name == 'Sunrise'
                ? Icons.wb_sunny_outlined
                : Icons.mosque_outlined,
            size: 18,
            color: muted,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 68,
            child: Text(
              localPrayerName(name, language),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 14,
                fontWeight: language == AppLanguage.english
                    ? FontWeight.w500
                    : FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: end == null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: _PrayerTimeCell(
                      key: ValueKey('prayer-time-$name'),
                      time: time,
                      language: language,
                      active: active,
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _PrayerTimeCell(
                          key: ValueKey('prayer-start-$name'),
                          time: time,
                          language: language,
                          active: active,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 1,
                        height: 24,
                        color: scheme.outlineVariant,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _PrayerTimeCell(
                          key: ValueKey('prayer-end-$name'),
                          time: end,
                          language: language,
                          active: active,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTimeCell extends StatelessWidget {
  const _PrayerTimeCell({
    super.key,
    required this.time,
    required this.language,
    required this.active,
  });

  final DateTime? time;
  final AppLanguage language;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final valueColor = active ? scheme.primary : scheme.onSurface;

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          localClock(time, language),
          maxLines: 1,
          style: TextStyle(
            color: valueColor,
            fontSize: language == AppLanguage.english ? 14 : 15,
            height: 1,
            fontWeight: language == AppLanguage.english
                ? FontWeight.w400
                : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MosqueTimesHeader extends StatelessWidget {
  const _MosqueTimesHeader({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = TextStyle(
      color: scheme.onSurfaceVariant,
      fontSize: language == AppLanguage.english ? 12 : 11,
      fontWeight: language == AppLanguage.english
          ? FontWeight.w500
          : FontWeight.w600,
    );

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(appText(language, 'সলাত', 'Salat'), style: style),
          ),
          Expanded(
            child: Text(
              appText(language, 'আজান', 'Azan'),
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 24, color: scheme.outlineVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              appText(language, 'জামাত', 'Jamaat'),
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

class _MosquePrayerRow extends StatelessWidget {
  const _MosquePrayerRow({
    required this.name,
    required this.calculatedAzan,
    required this.savedTime,
    required this.active,
    required this.language,
    required this.onAzanTap,
    required this.onJamaatTap,
  });

  final String name;
  final DateTime? calculatedAzan;
  final MosquePrayerTime? savedTime;
  final bool active;
  final AppLanguage language;
  final VoidCallback? onAzanTap;
  final VoidCallback? onJamaatTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final azan = _clockFromMinutes(savedTime?.azanMinutes) ?? calculatedAzan;
    final jamaat = _clockFromMinutes(savedTime?.jamaatMinutes);
    final foreground = active ? scheme.primary : scheme.onSurface;
    final muted = active ? scheme.primary : scheme.onSurfaceVariant;

    return Container(
      key: ValueKey('mosque-time-$name'),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
        color: active ? scheme.primaryContainer.withValues(alpha: 0.5) : null,
      ),
      child: Row(
        children: [
          Icon(
            name == 'Isha' ? Icons.nights_stay_outlined : Icons.mosque_outlined,
            size: 18,
            color: muted,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 68,
            child: Text(
              localPrayerName(name, language),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 14,
                fontWeight: language == AppLanguage.english
                    ? FontWeight.w500
                    : FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _MosqueTimeCell(
              cellKey: ValueKey('mosque-azan-$name'),
              time: azan,
              language: language,
              active: active,
              onTap: onAzanTap,
            ),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 24, color: scheme.outlineVariant),
          const SizedBox(width: 16),
          Expanded(
            child: _MosqueTimeCell(
              cellKey: ValueKey('mosque-jamaat-$name'),
              time: jamaat,
              language: language,
              active: active,
              onTap: onJamaatTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _MosqueTimeCell extends StatelessWidget {
  const _MosqueTimeCell({
    required this.cellKey,
    required this.time,
    required this.language,
    required this.active,
    required this.onTap,
  });

  final Key cellKey;
  final DateTime? time;
  final AppLanguage language;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = active ? scheme.primary : scheme.onSurface;

    return InkWell(
      key: cellKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            localClock(time, language),
            maxLines: 1,
            style: TextStyle(
              color: foreground,
              fontSize: language == AppLanguage.english ? 14 : 15,
              height: 1,
              fontWeight: language == AppLanguage.english
                  ? FontWeight.w400
                  : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

DateTime? _clockFromMinutes(int? minutes) =>
    minutes == null ? null : DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60);

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: scheme.onSurface),
        child: child,
      ),
    );
  }
}

class _ProhibitedTimeRow extends StatelessWidget {
  const _ProhibitedTimeRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        Text(
          ':',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

String _dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String? _localizedLocation(String? location, AppLanguage language) {
  if (location == null || language == AppLanguage.english) return location;
  final cityName = location.split(',').first.trim().toLowerCase();
  for (final city in bangladeshCities) {
    if (city.name.toLowerCase() == cityName) return '${city.bnName}, বাংলাদেশ';
  }
  return location.replaceAll('Bangladesh', 'বাংলাদেশ');
}

String _range(
  DateTime? end,
  int minutes,
  AppLanguage language, {
  bool after = false,
}) {
  if (end == null) return '—';
  return after
      ? '${localClock(end, language)}–${localClock(end.add(Duration(minutes: minutes)), language)}'
      : '${localClock(end.subtract(Duration(minutes: minutes)), language)}–${localClock(end, language)}';
}

double _qibla(double latitude, double longitude) {
  final lat = latitude * math.pi / 180;
  final delta = (39.8262 - longitude) * math.pi / 180;
  final targetLat = 21.4225 * math.pi / 180;
  return (math.atan2(
                math.sin(delta),
                math.cos(lat) * math.tan(targetLat) -
                    math.sin(lat) * math.cos(delta),
              ) *
              180 /
              math.pi +
          360) %
      360;
}
