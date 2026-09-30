import 'package:flutter/material.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../settings/domain/app_preferences.dart';
import '../data/nafl_prayer_times.dart';
import '../data/prayer_schedule.dart';

class NaflPrayerTimesCard extends StatelessWidget {
  const NaflPrayerTimesCard({
    super.key,
    required this.schedule,
    required this.now,
    required this.language,
    this.nextFajr,
    this.nextMaghrib,
    this.showFastingFooter = false,
    this.embedded = false,
  });

  final PrayerSchedule schedule;
  final DateTime now;
  final AppLanguage language;
  final DateTime? nextFajr;
  final DateTime? nextMaghrib;
  final bool showFastingFooter;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final nafl = NaflPrayerTimes.fromSchedule(
      schedule,
      now: now,
      nextFajr: nextFajr,
      nextMaghrib: nextMaghrib,
    );

    return Container(
      key: ValueKey(
        embedded ? 'calendar-nafl-prayer-times' : 'home-nafl-prayer-times',
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.fromLTRB(
        embedded ? 10 : 12,
        10,
        embedded ? 10 : 12,
        0,
      ),
      decoration: BoxDecoration(
        color: embedded
            ? scheme.surfaceContainerLowest
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(embedded ? 12 : 16),
        border: Border.all(
          color: scheme.primary.withValues(alpha: embedded ? 0.12 : 0.18),
        ),
        boxShadow: embedded
            ? null
            : [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.07),
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appText(
                    language,
                    'নফল সালাতের সময়',
                    'Nafl prayer times',
                  ),
                  style: TextStyle(
                    fontSize: embedded ? 13 : 15,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showReference(context),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  appText(language, 'রেফারেন্স দেখুন', 'View reference'),
                  style: TextStyle(fontSize: embedded ? 10 : 11),
                ),
              ),
            ],
          ),
          Divider(height: embedded ? 10 : 12),
          _NaflRow(
            icon: Icons.wb_sunny_outlined,
            label: appText(language, 'দুহা', 'Dhuha'),
            value: _clockRange(nafl.duhaStart, nafl.duhaEnd),
            compact: embedded,
          ),
          _NaflRow(
            icon: Icons.mosque_outlined,
            label: appText(language, 'জাওয়াল শুরু', 'Zawal begins'),
            value: localClock(nafl.zawalStart, language),
            compact: embedded,
          ),
          _NaflRow(
            icon: Icons.wb_cloudy_outlined,
            label: appText(language, 'আওয়াবিন', 'Awwabin'),
            value:
                '${appText(language, 'মাগরিবের পর', 'After Maghrib')} – ${localClock(nafl.awwabinEnd, language)}',
            compact: embedded,
          ),
          _NaflRow(
            icon: Icons.nights_stay_outlined,
            label: appText(language, 'তাহাজ্জুদ', 'Tahajjud'),
            value:
                '${appText(language, 'ইশার পর', 'After Isha')} – ${localClock(nafl.tahajjudEnd, language)}',
            compact: embedded,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: embedded ? 2 : 4,
              right: embedded ? 2 : 4,
              top: 1,
              bottom: embedded ? 8 : 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${appText(language, 'রাতের শেষ ১/৩ শুরু', 'Last third begins')}: ${localClock(nafl.lastThirdStart, language)}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: embedded ? 9.5 : 11,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showFastingFooter)
            _FastingFooter(nafl: nafl, now: now, language: language),
        ],
      ),
    );
  }

  String _clockRange(DateTime? start, DateTime? end) =>
      '${localClock(start, language)} – ${localClock(end, language)}';

  Future<void> _showReference(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          appText(
            language,
            'নফল সালাতের সময় সম্পর্কে',
            'About Nafl prayer times',
          ),
        ),
        content: Text(
          appText(
            language,
            'সময়গুলো হিসাবভিত্তিক ও আনুমানিক। দুহা সূর্যোদয়ের প্রায় ১৫ মিনিট পর থেকে যোহরের প্রায় ১০ মিনিট আগে পর্যন্ত দেখানো হয়। জাওয়াল শুরু যোহরের প্রায় ৫ মিনিট আগে দেখানো হয়। আওয়াবিন মাগরিবের পর থেকে ইশা পর্যন্ত এবং তাহাজ্জুদ ইশার পর থেকে ফজর পর্যন্ত দেখানো হয়। রাতের শেষ এক-তৃতীয়াংশ মাগরিব থেকে পরবর্তী ফজর পর্যন্ত রাতকে তিন ভাগ করে নির্ণয় করা হয়। স্থানীয় আলেম বা মসজিদের নির্দেশনা অগ্রাধিকার দিন।',
            'These are calculated approximate windows. Dhuha is shown from about 15 minutes after sunrise until about 10 minutes before Dhuhr. Zawal begins about 5 minutes before Dhuhr. Awwabin is shown from after Maghrib until Isha, and Tahajjud from after Isha until Fajr. The last third is calculated by dividing the night from Maghrib to the next Fajr into three equal parts. Follow local scholarly or mosque guidance when it differs.',
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

class _NaflRow extends StatelessWidget {
  const _NaflRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 3 : 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: compact ? 17 : 20,
            color: scheme.onSurfaceVariant,
          ),
          SizedBox(width: compact ? 7 : 9),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: compact ? 11 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 10.5 : 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FastingFooter extends StatelessWidget {
  const _FastingFooter({
    required this.nafl,
    required this.now,
    required this.language,
  });

  final NaflPrayerTimes nafl;
  final DateTime now;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final remaining = _durationText(nafl.iftarRemaining(now), language);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: -12),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.42),
            scheme.primaryContainer.withValues(alpha: 0.72),
          ],
        ),
      ),
      child: Row(
        children: [
          _FooterStat(
            value: localClock(nafl.nextSuhurEnd, language),
            label: appText(language, 'পরবর্তী সেহরি শেষ', 'Next suhur ends'),
          ),
          _FooterDivider(color: scheme.outlineVariant),
          _FooterStat(
            value: localClock(nafl.nextIftar, language),
            label: appText(language, 'পরবর্তী ইফতার', 'Next iftar'),
          ),
          _FooterDivider(color: scheme.outlineVariant),
          _FooterStat(
            value: remaining,
            label: appText(language, 'ইফতারের বাকি', 'Until iftar'),
          ),
        ],
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  const _FooterStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

class _FooterDivider extends StatelessWidget {
  const _FooterDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 38,
    color: color,
  );
}

String _durationText(Duration? value, AppLanguage language) {
  if (value == null || value.isNegative) return '—';
  final hours = value.inHours;
  final minutes = value.inMinutes.remainder(60);
  final seconds = value.inSeconds.remainder(60);
  final text =
      '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
  return localDigits(text, language);
}
