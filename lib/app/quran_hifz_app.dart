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
    final themeMode = switch (themePreference) {
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
      AppThemePreference.green => ThemeMode.light,
      AppThemePreference.women => ThemeMode.light,
    };

    return MaterialApp(
      title: 'YawMuslim',
      debugShowCheckedModeBanner: false,
      theme: appTheme(themePreference, language: language),
      darkTheme: appTheme(AppThemePreference.dark, language: language),
      themeMode: themeMode,
      home: const AppOpeningSplash(
        child: QuranContentBootstrapGate(
          child: OnboardingGate(completedChild: QuranHifzShell()),
        ),
      ),
    );
  }
}
