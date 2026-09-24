import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../hifz/presentation/hifz_planner_page.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/presentation/settings_page.dart';
import '../../study/presentation/bookmarks_page.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(appText(language, 'আরও', 'More')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MoreTile(
            icon: Icons.school_outlined,
            title: appText(language, 'হিফজ', 'Hifz'),
            subtitle: appText(
              language,
              'রেঞ্জ সংরক্ষণ করুন এবং সরাসরি অনুশীলন শুরু করুন',
              'Save ranges and start memorizing instantly',
            ),
            onTap: () => _open(context, const HifzPlannerPage()),
          ),
          _MoreTile(
            icon: Icons.bookmark_outline_rounded,
            title: appText(language, 'বুকমার্ক', 'Bookmarks'),
            subtitle: appText(
              language,
              'সংরক্ষিত আয়াত ও শব্দ',
              'Saved ayahs and words',
            ),
            onTap: () => _open(context, const BookmarksPage()),
          ),
          _MoreTile(
            icon: Icons.settings_outlined,
            title: appText(language, 'সেটিংস', 'Settings'),
            subtitle: appText(
              language,
              'পড়া, অনুবাদ ও অডিও',
              'Reading, translation and audio',
            ),
            onTap: () => _open(context, const SettingsPage()),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}
