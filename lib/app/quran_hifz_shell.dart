import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../core/localization/app_locale_text.dart';
import '../features/settings/application/app_preferences_controller.dart';
import '../features/settings/domain/app_preferences.dart';
import '../features/home/presentation/home_dashboard_page.dart';
import '../features/dua/presentation/dua_page.dart';
import '../features/home/presentation/more_page.dart';
import '../features/home/presentation/prayer_calendar_page.dart';
import '../features/quran/presentation/quran_surah_list_page.dart';
import 'app_destination.dart';

class QuranHifzShell extends ConsumerStatefulWidget {
  const QuranHifzShell({super.key});

  @override
  ConsumerState<QuranHifzShell> createState() => _QuranHifzShellState();
}

class _QuranHifzShellState extends ConsumerState<QuranHifzShell> {
  var _selectedIndex = 0;
  bool _exitDialogVisible = false;

  @override
  Widget build(BuildContext context) {
    final destination = AppDestination.values[_selectedIndex];
    final language = ref.watch(appLanguageProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmExit(language));
      },
      child: Scaffold(
        body: switch (destination) {
          AppDestination.home => HomeDashboardPage(
            onMore: () =>
                setState(() => _selectedIndex = AppDestination.more.index),
          ),
          AppDestination.dua => const DuaPage(),
          AppDestination.quran => const QuranSurahListPage(),
          AppDestination.calendar => const PrayerCalendarPage(),
          AppDestination.more => const MorePage(),
        },
        bottomNavigationBar: NavigationBar(
          height: 62,
          elevation: 0,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            if (index == _selectedIndex) return;
            setState(() => _selectedIndex = index);
          },
          destinations: [
            for (final item in AppDestination.values)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: appText(language, switch (item) {
                  AppDestination.home => 'হোম',
                  AppDestination.dua => 'দোয়া',
                  AppDestination.quran => 'কুরআন',
                  AppDestination.calendar => 'ক্যালেন্ডার',
                  AppDestination.more => 'আরও',
                }, item.label),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmExit(AppLanguage language) async {
    if (_exitDialogVisible || !mounted) return;
    _exitDialogVisible = true;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.exit_to_app_rounded),
        title: Text(appText(language, 'অ্যাপ বন্ধ করবেন?', 'Close the app?')),
        content: Text(
          appText(
            language,
            'আপনি কি YawMuslim অ্যাপটি বন্ধ করতে চান?',
            'Do you want to close YawMuslim?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(appText(language, 'বাতিল', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(appText(language, 'বন্ধ করুন', 'Close')),
          ),
        ],
      ),
    );
    _exitDialogVisible = false;
    if (shouldExit == true) await SystemNavigator.pop();
  }
}
