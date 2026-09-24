import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/todays_revision_controller.dart';

class TodaysRevisionPage extends ConsumerWidget {
  const TodaysRevisionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(todaysRevisionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Today's Revision")),
      body: groups.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Unable to load revision: $error'),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No Quran revision is due today.'));
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(todaysRevisionControllerProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final group = items[index];
                final range = group.startAyah == group.endAyah
                    ? '${group.startAyah}'
                    : '${group.startAyah}–${group.endAyah}';
                return Card(
                  child: ListTile(
                    title: Text('Surah ${group.surahNumber} · $range'),
                    subtitle: Text('${group.ayahCount} ayahs due'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
