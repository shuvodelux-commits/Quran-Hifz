import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/dua_providers.dart';
import '../domain/custom_dua.dart';
import '../domain/dua_entry.dart';
import 'custom_dua_detail_page.dart';
import 'custom_dua_form_page.dart';
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
    final customOnly = ref.watch(duaCustomOnlyProvider);
    final favoriteIds =
        ref.watch(duaFavoriteIdsProvider).value ?? const <String>{};
    final categoriesState = ref.watch(duaCategoriesProvider);
    final itemsState = ref.watch(visibleDuaEntriesProvider);

    final defaultMode =
        query.trim().isEmpty && selectedCategory == null && !customOnly;
    final heading = customOnly
        ? appText(language, 'আমার দোয়া', 'Custom Duas')
        : defaultMode
        ? appText(language, 'ফেভারিট দোয়া', 'Favorite Duas')
        : appText(language, 'দোয়ার তালিকা', 'Duas');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(appText(language, 'দোয়া', 'Dua')),
        centerTitle: true,
        actions: [
          IconButton(
            key: const ValueKey('custom-dua-add'),
            tooltip: appText(language, 'দোয়া যোগ করুন', 'Add Dua'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CustomDuaFormPage(),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
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
                  key: const ValueKey('dua-custom-filter'),
                  avatar: const Icon(Icons.person_outline_rounded, size: 18),
                  label: Text(appText(language, 'আমার দোয়া', 'Custom Duas')),
                  selected: customOnly,
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  showCheckmark: false,
                  onSelected: (value) {
                    ref.read(duaCustomOnlyProvider.notifier).setEnabled(value);
                    if (value) {
                      ref.read(duaCategoryProvider.notifier).select(null);
                    }
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: categoriesState.when(
                    data: (categories) => DuaCategoryFilter(
                      categories: categories,
                      language: language,
                      selectedId: selectedCategory,
                      onSelected: (id) {
                        ref
                            .read(duaCustomOnlyProvider.notifier)
                            .setEnabled(false);
                        ref.read(duaCategoryProvider.notifier).select(id);
                      },
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
              heading,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            itemsState.when(
              data: (items) => items.isEmpty
                  ? _EmptyState(
                      language: language,
                      defaultMode: defaultMode,
                      customOnly: customOnly,
                      onClear: _clearFilters,
                    )
                  : Column(
                      children: [
                        for (final entry in items)
                          DuaCard(
                            entry: entry,
                            language: language,
                            isFavorite: favoriteIds.contains(entry.id),
                            onFavorite: () async {
                              await ref
                                  .read(duaFavoriteIdsProvider.notifier)
                                  .toggle(entry.id);
                            },
                            onTap: () => _openEntry(entry),
                            onEdit: switch (entry) {
                              CustomDuaEntry(:final dua) =>
                                () => Navigator.of(context).push(
                                  MaterialPageRoute<CustomDua>(
                                    builder: (_) =>
                                        CustomDuaFormPage(initial: dua),
                                  ),
                                ),
                              VerifiedDuaEntry() => null,
                            },
                            onDelete: switch (entry) {
                              CustomDuaEntry(:final dua) =>
                                () => _confirmDeleteCustom(dua),
                              VerifiedDuaEntry() => null,
                            },
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
                  ref.invalidate(customDuasProvider);
                  ref.invalidate(visibleDuaEntriesProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEntry(DuaEntry entry) {
    switch (entry) {
      case VerifiedDuaEntry(:final dua):
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => DuaDetailPage(dua: dua)),
        );
      case CustomDuaEntry(:final dua):
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CustomDuaDetailPage(dua: dua),
          ),
        );
    }
  }

  Future<void> _confirmDeleteCustom(CustomDua dua) async {
    final language = ref.read(appLanguageProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(appText(language, 'দোয়া মুছবেন?', 'Delete Dua?')),
        content: Text(
          appText(
            language,
            'এই ব্যক্তিগত দোয়াটি স্থায়ীভাবে মুছে যাবে।',
            'This custom Dua will be permanently deleted.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(appText(language, 'বাতিল', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(appText(language, 'মুছুন', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(customDuasProvider.notifier).delete(dua.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appText(
              language,
              'দোয়া মুছতে সমস্যা হয়েছে',
              'Could not delete Dua',
            ),
          ),
        ),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(duaQueryProvider.notifier).clear();
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(duaQueryProvider.notifier).clear();
    ref.read(duaCategoryProvider.notifier).select(null);
    ref.read(duaCustomOnlyProvider.notifier).setEnabled(false);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.language,
    required this.defaultMode,
    required this.customOnly,
    required this.onClear,
  });

  final AppLanguage language;
  final bool defaultMode;
  final bool customOnly;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final message = defaultMode
        ? appText(
            language,
            'ফেভারিটে দোয়া যোগ করুন—এখানে দেখাবে।',
            'Add favorite duas to show them here.',
          )
        : customOnly
        ? appText(
            language,
            'এখনও কোনো ব্যক্তিগত দোয়া নেই',
            'No custom duas yet',
          )
        : appText(language, 'কোনো দোয়া পাওয়া যায়নি', 'No duas found');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 18),
      child: Column(
        children: [
          Icon(
            defaultMode
                ? Icons.favorite_border_rounded
                : customOnly
                ? Icons.person_outline_rounded
                : Icons.search_off_rounded,
            size: 34,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (!defaultMode) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onClear,
              child: Text(appText(language, 'ফিল্টার মুছুন', 'Clear filters')),
            ),
          ],
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
