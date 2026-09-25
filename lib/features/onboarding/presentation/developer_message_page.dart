import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/onboarding_controller.dart';
import 'onboarding_copy.dart';
import 'widgets/islamic_onboarding_hero.dart';

class DeveloperMessagePage extends ConsumerStatefulWidget {
  const DeveloperMessagePage({super.key});

  @override
  ConsumerState<DeveloperMessagePage> createState() =>
      _DeveloperMessagePageState();
}

class _DeveloperMessagePageState extends ConsumerState<DeveloperMessagePage> {
  bool _busy = false;

  Future<void> _complete(AppLanguage language) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(onboardingControllerProvider.notifier).complete();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            language == AppLanguage.bangla
                ? 'অগ্রগতি সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।'
                : 'Could not finish setup. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final bn = language == AppLanguage.bangla;
    final colors = Theme.of(context).colorScheme;
    const gold = Color(0xFFD5A44B);
    final email = onboardingSupportEmail?.trim();
    final hasEmail = email != null && email.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const IslamicOnboardingHero(
                icon: Icons.favorite_border_rounded,
                arabicLine: 'رَبِّ اغْفِرْ لَهُ وَارْحَمْهُ',
              ),
              Text(
                'STEP 3 OF 3',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                developerHeading(language),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                developerIntro(language),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    key: const ValueKey('developer-dedication-card'),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                Icons.favorite_border_rounded,
                                color: colors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                bn ? 'একটি দোয়ার অনুরোধ' : 'A request for dua',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          privacyMessage(language),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.6),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
                          decoration: BoxDecoration(
                            color: gold.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(11),
                            border: const Border(
                              left: BorderSide(color: gold, width: 3),
                            ),
                          ),
                          child: Text(
                            dedicationMessage(language),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.55,
                                ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          duaRequest(language),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.6),
                        ),
                        if (hasEmail) ...[
                          const SizedBox(height: 14),
                          Divider(color: colors.outlineVariant),
                          const SizedBox(height: 10),
                          Text(
                            supportIntro(language),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(height: 1.5),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.mail_outline_rounded,
                                color: colors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  email,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: colors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                key: const ValueKey('onboarding-start-app'),
                onPressed: _busy ? null : () => _complete(language),
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
                    : Text(bn ? 'আল কুরআন শুরু করুন' : 'Start Al Quran'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
