import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../quran/application/todays_ayah.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/mosque_prayer_times_providers.dart';
import '../application/prayer_tracker_providers.dart';
import '../data/bangla_calendar.dart';
import '../data/bangladesh_cities.dart';
import '../data/mosque_prayer_times_repository.dart';
import '../data/prayer_schedule.dart';
import 'home_page.dart' show prayerScheduleProvider;
import 'prayer_location_page.dart';

class HomeDashboardPage extends ConsumerStatefulWidget {
  const HomeDashboardPage({
    super.key,
    required this.onMore,
    required this.onPrayer,
  });
  final VoidCallback onMore;
  final VoidCallback onPrayer;

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
    final dayKey = _dateKey(_now);
    final completed =
        ref.watch(dailyPrayerChecksProvider(dayKey)).value ?? <String>{};
    final mosqueTimesState = ref.watch(mosquePrayerTimesProvider);
    final mosqueTimes = mosqueTimesState.value ?? {};
    final mosqueTimesReady = mosqueTimesState.hasValue;
    final next = schedule?.nextPrayer(_now);
    final todaysAyah = ref.watch(todaysAyahProvider).value;

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
                                      appText(language, 'অবস্থান', 'Location'),
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
                            schedule == null
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
              _DateHero(now: _now, schedule: schedule, language: language),
              const SizedBox(height: 8),
              _NextPrayerCard(
                next: next,
                now: _now,
                onTap: widget.onPrayer,
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
                              active: next?.name == name,
                              completed: completed.contains(name),
                              language: language,
                              onTap: name == 'Sunrise'
                                  ? null
                                  : () => _toggle(dayKey, name),
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
                              active: next?.name == name,
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
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
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

  Future<void> _toggle(String dayKey, String name) async {
    await toggleDailyPrayer(ref, dayKey, name);
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
    required this.language,
  });
  final DateTime now;
  final PrayerSchedule? schedule;
  final AppLanguage language;
  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('home-date-summary'),
    padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Row(
          children: [
            _DateColumn(
              icon: Icons.nights_stay_outlined,
              value: localHijriDate(
                schedule?.hijriDateAt(now) ?? '—',
                language,
              ),
              label: appText(language, 'হিজরি', 'Hijri'),
            ),
            const _HeroDivider(),
            _DateColumn(
              icon: Icons.calendar_today_outlined,
              value: localGregorianDate(now, language),
              label: appText(language, 'গ্রেগরিয়ান', 'Gregorian'),
            ),
            const _HeroDivider(),
            _DateColumn(
              icon: Icons.auto_awesome_outlined,
              value: banglaCalendarDate(
                now,
                english: language == AppLanguage.english,
              ),
              label: appText(language, 'বাংলা', 'Bangla'),
            ),
          ],
        ),
        Divider(
          color: Theme.of(
            context,
          ).colorScheme.onPrimary.withValues(alpha: 0.35),
          height: 14,
        ),
        Row(
          children: [
            Expanded(
              child: _SunLine(
                icon: Icons.wb_sunny_outlined,
                label: appText(language, 'সূর্যোদয়', 'Sunrise'),
                time: schedule?.sunrise,
                language: language,
              ),
            ),
            Container(
              width: 1,
              height: 30,
              color: Theme.of(
                context,
              ).colorScheme.onPrimary.withValues(alpha: 0.4),
            ),
            Expanded(
              child: _SunLine(
                icon: Icons.wb_twilight_outlined,
                label: appText(language, 'সূর্যাস্ত', 'Sunset'),
                time: schedule?.sunset,
                language: language,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _HeroDivider extends StatelessWidget {
  const _HeroDivider();
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 60,
    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.35),
  );
}

class _DateColumn extends StatelessWidget {
  const _DateColumn({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 18),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onPrimary.withValues(alpha: 0.78),
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

class _SunLine extends StatelessWidget {
  const _SunLine({
    required this.icon,
    required this.label,
    required this.time,
    required this.language,
  });
  final IconData icon;
  final String label;
  final DateTime? time;
  final AppLanguage language;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 20),
      const SizedBox(width: 5),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onPrimary.withValues(alpha: 0.78),
              fontSize: 11,
            ),
          ),
          Text(
            localClock(time, language),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ],
  );
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({
    required this.next,
    required this.now,
    required this.onTap,
    required this.language,
  });
  final ({String name, DateTime time})? next;
  final DateTime now;
  final VoidCallback onTap;
  final AppLanguage language;
  @override
  Widget build(BuildContext context) {
    final remaining = next?.time.difference(now);
    return _Panel(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Icon(
                Icons.mosque_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appText(language, 'পরবর্তী সলাত', 'Next Prayer'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    next == null ? '—' : localPrayerName(next!.name, language),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    localClock(next?.time, language),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 44,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                Text(
                  appText(language, 'শুরু হতে বাকি', 'Starts in'),
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  remaining == null ? '—' : localCountdown(remaining, language),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
          ],
        ),
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
    required this.completed,
    required this.language,
    this.onTap,
  });
  final String name;
  final DateTime? time;
  final DateTime? end;
  final bool active;
  final bool completed;
  final AppLanguage language;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      key: ValueKey('prayer-row-$name'),
      constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        color: active
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.5)
            : null,
      ),
      child: Row(
        children: [
          Icon(
            name == 'Isha'
                ? Icons.nights_stay_outlined
                : name == 'Sunrise'
                ? Icons.wb_sunny_outlined
                : Icons.mosque_outlined,
            size: 20,
            color: active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 82,
            child: Text(
              localPrayerName(name, language),
              style: TextStyle(
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              end == null
                  ? localClock(time, language)
                  : _prayerWindow(time, end!, language),
              maxLines: 1,
              style: TextStyle(
                fontSize: end == null
                    ? (language == AppLanguage.english ? 14 : 16)
                    : (language == AppLanguage.english ? 12 : 14),
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            onTap == null
                ? Icons.remove_circle_outline
                : completed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: onTap == null
                ? Theme.of(context).colorScheme.outline
                : completed
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            size: 20,
          ),
        ],
      ),
    ),
  );
}

String _prayerWindow(DateTime? start, DateTime end, AppLanguage language) {
  if (start == null) return '—';
  if (language == AppLanguage.bangla) {
    return '${localClock(start, language)} – ${localClock(end, language)}';
  }

  String clock(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    return '${hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  final startPeriod = start.hour < 12 ? 'AM' : 'PM';
  final endPeriod = end.hour < 12 ? 'AM' : 'PM';
  if (startPeriod == endPeriod) {
    return '${clock(start)}–${clock(end)} $endPeriod';
  }
  return '${clock(start)} $startPeriod–${clock(end)} $endPeriod';
}

class _MosqueTimesHeader extends StatelessWidget {
  const _MosqueTimesHeader({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            appText(language, 'সলাত', 'Salat'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            appText(language, 'আজান', 'Azan'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            appText(language, 'জামাত', 'Jamaat'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 28),
      ],
    ),
  );
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
    final azan = _clockFromMinutes(savedTime?.azanMinutes) ?? calculatedAzan;
    final jamaat = _clockFromMinutes(savedTime?.jamaatMinutes);
    final foreground = active
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;
    return Container(
      key: ValueKey('mosque-time-$name'),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        color: active
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.5)
            : null,
      ),
      child: Row(
        children: [
          Icon(
            name == 'Isha' ? Icons.nights_stay_outlined : Icons.mosque_outlined,
            size: 20,
            color: active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 82,
            child: Text(
              localPrayerName(name, language),
              style: TextStyle(
                color: foreground,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              key: ValueKey('mosque-azan-$name'),
              onTap: onAzanTap,
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Text(
                  localClock(azan, language),
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              key: ValueKey('mosque-jamaat-$name'),
              onTap: onJamaatTap,
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Text(
                  localClock(jamaat, language),
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: IconButton(
              key: ValueKey('mosque-edit-$name'),
              tooltip: appText(
                language,
                'আজানের সময় সম্পাদনা',
                'Edit Azan time',
              ),
              onPressed: onAzanTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 28, height: 36),
              icon: Icon(
                Icons.edit_outlined,
                color: onAzanTap == null
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ),
          ),
        ],
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: child,
  );
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
