import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/presentation/prayer_location_page.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/onboarding_controller.dart';
import 'widgets/islamic_onboarding_hero.dart';

class LocationOnboardingPage extends ConsumerStatefulWidget {
  const LocationOnboardingPage({super.key});

  @override
  ConsumerState<LocationOnboardingPage> createState() =>
      _LocationOnboardingPageState();
}

class _LocationOnboardingPageState
    extends ConsumerState<LocationOnboardingPage> {
  bool _busy = false;

  Future<void> _useCurrentLocation() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(onboardingControllerProvider.notifier)
          .useCurrentLocation();
    } catch (_) {
      if (!mounted) return;
      final language = ref.read(appLanguageProvider);
      _showError(
        language == AppLanguage.bangla
            ? 'লোকেশন সেট করা যায়নি। আবার চেষ্টা করুন, ম্যানুয়ালি নির্বাচন করুন অথবা পরে সেট করুন।'
            : 'Could not set your location. Try again, choose manually, or set it later.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _chooseManually() async {
    if (_busy) return;
    final configured = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const PrayerLocationPage(manualOnly: true),
      ),
    );
    if (configured != true || !mounted) return;
    try {
      await ref
          .read(onboardingControllerProvider.notifier)
          .goToDeveloperMessage();
    } catch (_) {
      if (!mounted) return;
      final language = ref.read(appLanguageProvider);
      _showError(
        language == AppLanguage.bangla
            ? 'অগ্রগতি সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।'
            : 'Could not save your progress. Please try again.',
      );
    }
  }

  Future<void> _skip() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(onboardingControllerProvider.notifier).skipLocation();
    } catch (_) {
      if (!mounted) return;
      final language = ref.read(appLanguageProvider);
      _showError(
        language == AppLanguage.bangla
            ? 'অগ্রগতি সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।'
            : 'Could not save your progress. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final bn = language == AppLanguage.bangla;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const IslamicOnboardingHero(
                icon: Icons.location_on_outlined,
                arabicLine: 'وَأَقِيمُوا الصَّلَاةَ',
              ),
              Text(
                'STEP 2 OF 3',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bn ? 'লোকেশন সেট করুন' : 'Set location',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bn
                    ? 'আপনার এলাকার সঠিক সালাতের সময় দেখাতে লোকেশন নির্বাচন করুন। চাইলে এখন বাদ দিয়ে পরে সেট করতে পারবেন।'
                    : 'Choose your location for accurate prayer times. You can also skip this and set it later.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                key: const ValueKey('onboarding-location-current'),
                onPressed: _busy ? null : _useCurrentLocation,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _busy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_outlined),
                label: Text(
                  bn ? 'বর্তমান লোকেশন ব্যবহার করুন' : 'Use current location',
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                key: const ValueKey('onboarding-location-manual'),
                onPressed: _busy ? null : _chooseManually,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.map_outlined),
                label: Text(
                  bn ? 'ম্যানুয়ালি নির্বাচন করুন' : 'Choose manually',
                ),
              ),
              const Spacer(),
              TextButton(
                key: const ValueKey('onboarding-location-later'),
                onPressed: _busy ? null : _skip,
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(bn ? 'পরে সেট করুন' : 'Set up later'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
