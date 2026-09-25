import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/prayer_schedule.dart';
import '../data/bangladesh_cities.dart';
import '../data/user_database_prayer_location_store.dart';
import '../../../core/database/database_providers.dart';
import '../../settings/application/app_preferences_controller.dart';

final prayerLocationStoreProvider = Provider<PrayerLocationStore>(
  (ref) => UserDatabasePrayerLocationStore(ref.watch(userDatabaseProvider)),
);

final savedPrayerLocationProvider = FutureProvider<PrayerLocation?>(
  (ref) => ref.watch(prayerLocationStoreProvider).load(),
);

final prayerScheduleRepositoryProvider = Provider<PrayerScheduleRepository>(
  (ref) => PrayerScheduleRepository(
    locationStore: ref.watch(prayerLocationStoreProvider),
  ),
);
final prayerScheduleProvider = FutureProvider<PrayerSchedule>(
  (ref) => ref
      .watch(prayerScheduleRepositoryProvider)
      .load(
        DateTime.now(),
        school: ref.watch(asrSchoolProvider),
        selectedLocation: bangladeshCityById(ref.watch(prayerCityIdProvider)),
      ),
);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.onSettings});

  final VoidCallback onSettings;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Timer? _clock;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final next = DateTime.now();
      if (next.day != _now.day ||
          next.month != _now.month ||
          next.year != _now.year) {
        ref.invalidate(prayerScheduleProvider);
      }
      setState(() => _now = next);
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schedule = ref.watch(prayerScheduleProvider);
    final data = schedule.value;
    final ink = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(prayerScheduleProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data?.location ?? 'আপনার অবস্থান',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            color: ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'আজকের সলাতের সময়',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Settings',
                    onPressed: widget.onSettings,
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _HeroCard(now: _now, schedule: data),
              const SizedBox(height: 14),
              _PrayerCard(now: _now, schedule: data, error: schedule.error),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Shortcut(
                    icon: Icons.calendar_month_outlined,
                    label: 'ক্যালেন্ডার',
                    onTap: _openCalendar,
                  ),
                  _Shortcut(
                    icon: Icons.explore_outlined,
                    label: 'কিবলা',
                    onTap: () => _showQibla(data),
                  ),
                  _Shortcut(
                    icon: Icons.more_horiz_rounded,
                    label: 'আরও',
                    onTap: widget.onSettings,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: 'আজকের সময়সূচী',
                icon: Icons.schedule_rounded,
                rows: [
                  ('সূর্যোদয়', data == null ? '—' : _clockText(data.sunrise)),
                  ('সূর্যাস্ত', data == null ? '—' : _clockText(data.sunset)),
                  ('রাত শুরু', data == null ? '—' : _clockText(data.sunset)),
                ],
              ),
              const SizedBox(height: 12),
              _InfoCard(
                title: 'ইসলামিক তারিখ',
                icon: Icons.calendar_today_outlined,
                rows: [
                  ('হিজরি', data?.hijriDateAt(_now) ?? '—'),
                  (
                    'ইংরেজি',
                    '${_now.day} ${_months[_now.month - 1]} ${_now.year}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ProhibitedCard(schedule: data),
              const SizedBox(height: 12),
              _Card(
                child: Row(
                  children: [
                    const _IconDisc(Icons.mosque_outlined),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'আজকের দোয়া',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'رَبِّ زِدْنِي عِلْمًا',
                            style: TextStyle(fontSize: 24),
                          ),
                          Text(
                            'হে আমার রব, আমার জ্ঞান বাড়িয়ে দিন। · সূরা ত্বহা ২০:১১৪',
                            style: TextStyle(
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

  Future<void> _openCalendar() async {
    await showDatePicker(
      context: context,
      initialDate: _now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
  }

  void _showQibla(PrayerSchedule? schedule) {
    if (schedule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কিবলার জন্য অবস্থান চালু করুন।')),
      );
      return;
    }
    const kaabaLat = 21.4225 * math.pi / 180;
    const kaabaLon = 39.8262 * math.pi / 180;
    final lat = schedule.latitude * math.pi / 180;
    final delta = kaabaLon - schedule.longitude * math.pi / 180;
    final bearing =
        (math.atan2(
                  math.sin(delta),
                  math.cos(lat) * math.tan(kaabaLat) -
                      math.sin(lat) * math.cos(delta),
                ) *
                180 /
                math.pi +
            360) %
        360;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore_rounded,
              size: 54,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              'কিবলার দিক ${bearing.round()}°',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text('উত্তর দিক থেকে ঘড়ির কাঁটার দিকে মাপা।'),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.now, required this.schedule});
  final DateTime now;
  final PrayerSchedule? schedule;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.13),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  schedule?.hijriDateAt(now) ?? 'ইসলামিক তারিখ',
                  maxLines: 2,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${now.day} ${_months[now.month - 1]} ${now.year}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 72,
            color: Theme.of(
              context,
            ).colorScheme.onPrimary.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 18),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SunEvent(
                label: 'সূর্যোদয়',
                icon: Icons.wb_sunny_outlined,
                time: schedule?.sunrise,
              ),
              const SizedBox(height: 9),
              _SunEvent(
                label: 'সূর্যাস্ত',
                icon: Icons.wb_twilight_outlined,
                time: schedule?.sunset,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunEvent extends StatelessWidget {
  const _SunEvent({
    required this.label,
    required this.icon,
    required this.time,
  });
  final String label;
  final IconData icon;
  final DateTime? time;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 20),
      const SizedBox(width: 5),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 11,
            ),
          ),
          Text(
            time == null ? '—' : _clockText(time!),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ],
  );
}

class _PrayerCard extends StatelessWidget {
  const _PrayerCard({required this.now, required this.schedule, this.error});
  final DateTime now;
  final PrayerSchedule? schedule;
  final Object? error;
  @override
  Widget build(BuildContext context) {
    final next = schedule?.nextPrayer(now);
    final remaining = next == null ? null : next.time.difference(now);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Next prayer',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      next?.name ?? '—',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _IconDisc(Icons.mosque_outlined),
                    const SizedBox(height: 7),
                    Text(
                      remaining == null ? '—' : _durationText(remaining),
                      style: TextStyle(
                        fontSize: 25,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'বাকি আছে',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 210,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    for (final name in prayerNames)
                      Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          color: next?.name == name
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              name == 'Isha'
                                  ? Icons.nights_stay_outlined
                                  : Icons.wb_twilight_outlined,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              schedule?.times[name] == null
                                  ? '—'
                                  : _clockText(schedule!.times[name]!),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
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
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                error is StateError
                    ? (error as StateError).message
                    : 'Select a location once for offline prayer times.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: _Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 88,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _IconDisc(icon),
                const SizedBox(height: 7),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.rows,
  });
  final String title;
  final IconData icon;
  final List<(String, String)> rows;
  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 9),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 7),
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Text(label),
                const Spacer(),
                Flexible(
                  child: Text(
                    value,
                    maxLines: 2,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _ProhibitedCard extends StatelessWidget {
  const _ProhibitedCard({required this.schedule});
  final PrayerSchedule? schedule;
  @override
  Widget build(BuildContext context) {
    final dhuhr = schedule?.times['Dhuhr'];
    final sunset = schedule?.sunset;
    return _InfoCard(
      title: 'সলাতের নিষিদ্ধ সময় (আনুমানিক)',
      icon: Icons.info_outline_rounded,
      rows: [
        (
          'সকাল',
          schedule == null
              ? '—'
              : '${_clockText(schedule!.sunrise)}–${_clockText(schedule!.sunrise.add(const Duration(minutes: 15)))}',
        ),
        (
          'দুপুর',
          dhuhr == null
              ? '—'
              : '${_clockText(dhuhr.subtract(const Duration(minutes: 5)))}–${_clockText(dhuhr)}',
        ),
        (
          'সন্ধ্যা',
          sunset == null
              ? '—'
              : '${_clockText(sunset.subtract(const Duration(minutes: 15)))}–${_clockText(sunset)}',
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

class _IconDisc extends StatelessWidget {
  const _IconDisc(this.icon);
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
    child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
  );
}

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _clockText(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  return _bangla(
    '${hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
  );
}

String _durationText(Duration value) {
  final seconds = value.inSeconds.clamp(0, 86400);
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final rest = seconds % 60;
  return _bangla(
    '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${rest.toString().padLeft(2, '0')}',
  );
}

String _bangla(String input) => input.replaceAllMapped(
  RegExp(r'\d'),
  (match) => '০১২৩৪৫৬৭৮৯'[int.parse(match.group(0)!)],
);
