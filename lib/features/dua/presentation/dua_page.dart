import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/dua_providers.dart';
import 'dua_detail_page.dart';
import 'widgets/dua_card.dart';
import 'widgets/dua_category_filter.dart';

class DuaPage extends ConsumerStatefulWidget {
  const DuaPage({super.key});

  @override
  ConsumerState<DuaPage> createState() => _DuaPageState();
}

class _DuaPageState extends ConsumerState<DuaPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final query = ref.watch(duaQueryProvider);
    final selectedCategory = ref.watch(duaCategoryProvider);
    final favoritesOnly = ref.watch(duaFavoritesOnlyProvider);
    final favoriteIds =
        ref.watch(duaFavoriteIdsProvider).value ?? const <String>{};
    final categoriesState = ref.watch(duaCategoriesProvider);
    final defaultMode =
        query.trim().isEmpty && selectedCategory == null && !favoritesOnly;
    final itemsState = defaultMode
        ? ref.watch(dailyDuasProvider)
        : ref.watch(filteredDuasProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(appText(language, 'দোয়া', 'Dua')),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
          children: [
            TextField(
              key: const ValueKey('dua-search-field'),
              controller: _searchController,
              onChanged: (value) =>
                  ref.read(duaQueryProvider.notifier).setQuery(value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: appText(language, 'দোয়া খুঁজুন', 'Search duas'),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: appText(
                          language,
                          'সার্চ মুছুন',
                          'Clear search',
                        ),
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close_rounded),
                      ),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                FilterChip(
                  key: const ValueKey('dua-favorites-filter'),
                  avatar: Icon(
                    favoritesOnly
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 18,
                  ),
                  label: Text(appText(language, 'ফেভারিট', 'Favorites')),
                  selected: favoritesOnly,
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  showCheckmark: false,
                  onSelected: (value) => ref
                      .read(duaFavoritesOnlyProvider.notifier)
                      .setEnabled(value),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: categoriesState.when(
                    data: (categories) => DuaCategoryFilter(
                      categories: categories,
                      language: language,
                      selectedId: selectedCategory,
                      onSelected: (id) =>
                          ref.read(duaCategoryProvider.notifier).select(id),
                    ),
                    loading: () => const SizedBox(
                      height: 34,
                      child: LinearProgressIndicator(),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              defaultMode
                  ? appText(language, 'দৈনিক দোয়া', 'Daily Duas')
                  : favoritesOnly
                  ? appText(language, 'ফেভারিট দোয়া', 'Favorite Duas')
                  : appText(language, 'দোয়ার তালিকা', 'Duas'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            itemsState.when(
              data: (items) => items.isEmpty
                  ? _EmptyState(
                      language: language,
                      favoritesOnly: favoritesOnly,
                      onClear: _clearFilters,
                    )
                  : Column(
                      children: [
                        for (final dua in items)
                          DuaCard(
                            dua: dua,
                            language: language,
                            isFavorite: favoriteIds.contains(dua.id),
                            onFavorite: () async {
                              await ref
                                  .read(duaFavoriteIdsProvider.notifier)
                                  .toggle(dua.id);
                            },
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => DuaDetailPage(dua: dua),
                              ),
                            ),
                          ),
                      ],
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => _LoadError(
                language: language,
                onRetry: () {
                  ref.invalidate(duaCatalogProvider);
                  ref.invalidate(duaCategoriesProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(duaQueryProvider.notifier).clear();
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(duaQueryProvider.notifier).clear();
    ref.read(duaCategoryProvider.notifier).select(null);
    ref.read(duaFavoritesOnlyProvider.notifier).setEnabled(false);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.language,
    required this.favoritesOnly,
    required this.onClear,
  });

  final AppLanguage language;
  final bool favoritesOnly;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 18),
      child: Column(
        children: [
          Icon(
            favoritesOnly
                ? Icons.favorite_border_rounded
                : Icons.search_off_rounded,
            size: 34,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            favoritesOnly
                ? appText(
                    language,
                    'এখনও কোনো ফেভারিট দোয়া নেই',
                    'No favorite duas yet',
                  )
                : appText(language, 'কোনো দোয়া পাওয়া যায়নি', 'No duas found'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onClear,
            child: Text(appText(language, 'ফিল্টার মুছুন', 'Clear filters')),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.language, required this.onRetry});

  final AppLanguage language;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 34),
    child: Column(
      children: [
        Text(
          appText(
            language,
            'দোয়ার তালিকা লোড করা যায়নি',
            'Could not load the Dua library',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onRetry,
          child: Text(appText(language, 'আবার চেষ্টা করুন', 'Retry')),
        ),
      ],
    ),
  );
}
