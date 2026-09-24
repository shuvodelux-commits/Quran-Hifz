import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/search_providers.dart';
import '../domain/quran_search_result.dart';

class QuranSearchPage extends ConsumerStatefulWidget {
  const QuranSearchPage({super.key});

  @override
  ConsumerState<QuranSearchPage> createState() => _QuranSearchPageState();
}

class _QuranSearchPageState extends ConsumerState<QuranSearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.trim().isEmpty
        ? const AsyncValue<List<QuranSearchResult>>.data([])
        : ref.watch(quranSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Search Quran')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SearchBar(
              controller: _controller,
              hintText: 'Surah, 2:255, or Bangla translation',
              leading: const Icon(Icons.search_rounded),
              onChanged: (value) => setState(() => _query = value),
              trailing: [
                if (_query.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
            ),
          ),
          Expanded(
            child: results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(
                child: Text(
                  'Quran search is unavailable until verified content is installed.',
                ),
              ),
              data: (items) {
                if (_query.trim().isEmpty) {
                  return const Center(
                    child: Text(
                      'Search by Surah name, Surah number, ayah reference, or Bangla text.',
                    ),
                  );
                }
                if (items.isEmpty) {
                  return const Center(child: Text('No Quran results found.'));
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(
                        item.type == QuranSearchResultType.ayah
                            ? '${item.verseKey}  ${item.title}'
                            : '${item.surahNumber}. ${item.title}',
                        textDirection: item.type == QuranSearchResultType.ayah
                            ? TextDirection.rtl
                            : null,
                      ),
                      subtitle: item.matchText != null
                          ? Text(item.matchText!)
                          : item.subtitle != null
                          ? Text(item.subtitle!)
                          : null,
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).pop(item.pageNumber),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
