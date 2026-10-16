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
      // Quran and Hifz must never inherit Android text scaling: they have
      // independent in-app sizing controls. Optional Android accessibility
      // scaling is applied to the ordinary UI Theme only.
      builder: (context, child) {
        final fixedReaderScale = MediaQuery.withNoTextScaling(
          child: child ?? const SizedBox.shrink(),
        );
        if (!followSystemTextSize) return fixedReaderScale;
        final androidScale =
            MediaQuery.textScalerOf(context).scale(16) / 16;
        final effectiveUiScale =
            (uiFontScale * androidScale).clamp(0.85, 2.0).toDouble();
        return Theme(
          data: appTheme(
            themePreference,
            language: language,
            uiFontScale: effectiveUiScale,
            uiLineHeightScale: uiLineHeightScale,
          ),
          child: fixedReaderScale,
        );
      },
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
