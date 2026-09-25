import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/onboarding_controller.dart';
import 'widgets/islamic_onboarding_hero.dart';

class LanguageOnboardingPage extends ConsumerStatefulWidget {
  const LanguageOnboardingPage({super.key});

  @override
  ConsumerState<LanguageOnboardingPage> createState() =>
      _LanguageOnboardingPageState();
}

class _LanguageOnboardingPageState
    extends ConsumerState<LanguageOnboardingPage> {
  bool _busy = false;

  Future<void> _setLanguage(AppLanguage language) async {
    if (_busy) return;
    try {
      await ref
          .read(appPreferencesControllerProvider.notifier)
          .setLanguage(language);
    } catch (_) {
      if (!mounted) return;
      _showError(
        language == AppLanguage.bangla
            ? 'ভাষা সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।'
            : 'Could not save the language. Please try again.',
      );
    }
  }

  Future<void> _continue(AppLanguage language) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(onboardingControllerProvider.notifier)
          .selectLanguage(language);
    } catch (_) {
      if (!mounted) return;
      _showError(
        language == AppLanguage.bangla
            ? 'ভাষা সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।'
            : 'Could not save the language. Please try again.',
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
                icon: Icons.nights_stay_outlined,
                arabicLine: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              ),
              Text(
                'STEP 1 OF 3',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bn ? 'আপনার ভাষা নির্বাচন করুন' : 'Choose your language',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bn
                    ? 'আরামদায়কভাবে কুরআন পড়া ও অ্যাপ ব্যবহার করার জন্য আপনার পছন্দের ভাষা বেছে নিন। পরে সেটিংস থেকে পরিবর্তন করা যাবে।'
                    : 'Choose the language you prefer for reading and using the app. You can change it later in Settings.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),
              _LanguageOption(
                key: const ValueKey('language-option-bangla'),
                title: 'বাংলা',
                subtitle: 'বাংলা ইন্টারফেস',
                selected: language == AppLanguage.bangla,
                onTap: _busy ? null : () => _setLanguage(AppLanguage.bangla),
              ),
              const SizedBox(height: 10),
              _LanguageOption(
                key: const ValueKey('language-option-english'),
                title: 'English',
                subtitle: 'English interface',
                selected: language == AppLanguage.english,
                onTap: _busy ? null : () => _setLanguage(AppLanguage.english),
              ),
              const Spacer(),
              FilledButton(
                key: const ValueKey('onboarding-language-next'),
                onPressed: _busy ? null : () => _continue(language),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _busy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(bn ? 'পরবর্তী' : 'Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 58),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
