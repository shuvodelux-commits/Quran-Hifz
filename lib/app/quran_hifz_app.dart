import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/onboarding/presentation/onboarding_gate.dart';
import '../features/settings/application/app_preferences_controller.dart';
import '../features/settings/domain/app_preferences.dart';
import 'app_theme.dart';
import 'app_opening_splash.dart';
import 'quran_content_bootstrap_gate.dart';
import 'quran_hifz_shell.dart';

class QuranHifzApp extends ConsumerWidget {
  const QuranHifzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePreference = ref.watch(themePreferenceProvider);
    final language = ref.watch(appLanguageProvider);
    final uiFontScale = ref.watch(uiFontScaleProvider);
    final uiLineHeightScale = ref.watch(uiLineHeightScaleProvider);
    final followSystemTextSize = ref.watch(followSystemTextSizeProvider);
    final themeMode = switch (themePreference) {
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
      AppThemePreference.green => ThemeMode.light,
      AppThemePreference.women => ThemeMode.light,
    };

    return MaterialApp(
      title: 'Quran Hifz',
      debugShowCheckedModeBanner: false,
      // Same readable baseline on different phones. Users may opt in to their
      // Android large-text preference from the in-app typography settings.
      builder: (context, child) => followSystemTextSize
          ? child ?? const SizedBox.shrink()
          : MediaQuery.withNoTextScaling(
              child: child ?? const SizedBox.shrink(),
            ),
      theme: appTheme(
        themePreference,
        language: language,
        uiFontScale: uiFontScale,
        uiLineHeightScale: uiLineHeightScale,
      ),
      darkTheme: appTheme(
        AppThemePreference.dark,
        language: language,
        uiFontScale: uiFontScale,
        uiLineHeightScale: uiLineHeightScale,
      ),
      themeMode: themeMode,
      home: const AppOpeningSplash(
        child: QuranContentBootstrapGate(
          child: OnboardingGate(completedChild: QuranHifzShell()),
        ),
      ),
    );
  }
}
