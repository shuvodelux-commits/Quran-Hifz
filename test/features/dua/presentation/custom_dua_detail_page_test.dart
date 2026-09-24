import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/dua/application/dua_providers.dart';
import 'package:quran_hifz/features/dua/domain/custom_dua.dart';
import 'package:quran_hifz/features/dua/domain/custom_dua_repository.dart';
import 'package:quran_hifz/features/dua/domain/dua_entry.dart';
import 'package:quran_hifz/features/dua/domain/dua_favorites_repository.dart';
import 'package:quran_hifz/features/dua/presentation/custom_dua_detail_page.dart';
import 'package:quran_hifz/features/dua/presentation/widgets/dua_card.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  final custom = CustomDua(
    id: 'custom:one',
    title: 'Personal morning dua',
    arabic: 'اللهم بارك لي',
    transliteration: 'Allahumma barik li',
    meaning: 'Bless me',
    reference: 'Copied from my notebook',
    createdAt: DateTime.utc(2026, 9, 24, 8),
    updatedAt: DateTime.utc(2026, 9, 24, 8),
  );

  testWidgets('custom card shows personal label and user reference only', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DuaCard(
            entry: CustomDuaEntry(custom),
            language: AppLanguage.english,
            isFavorite: false,
            onFavorite: () {},
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Personal morning dua'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
    expect(find.text('Copied from my notebook'), findsOneWidget);
    expect(find.byKey(const ValueKey('dua-source-primary')), findsNothing);
  });

  testWidgets('custom detail renders exact content without verified grading', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      dua: custom,
      language: AppLanguage.english,
      repository: _MemoryCustomDuaRepository([custom]),
      favorites: _MemoryFavoritesRepository(),
    );

    for (final text in const [
      'Personal morning dua',
      'اللهم بارك لي',
      'Allahumma barik li',
      'Bless me',
      'Copied from my notebook',
      'Custom',
    ]) {
      expect(find.text(text), findsOneWidget);
    }

    expect(find.textContaining('Sahih'), findsNothing);
    expect(find.textContaining('Hasan'), findsNothing);
    expect(find.byKey(const ValueKey('dua-source-primary')), findsNothing);
    expect(
      find.byKey(const ValueKey('custom-dua-detail-edit')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('custom-dua-detail-delete')),
      findsOneWidget,
    );
  });

  testWidgets('Bangla custom detail keeps user content and personal badge', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      dua: custom,
      language: AppLanguage.bangla,
      repository: _MemoryCustomDuaRepository([custom]),
      favorites: _MemoryFavoritesRepository(),
    );

    expect(find.text('ব্যক্তিগত দোয়া'), findsOneWidget);
    expect(find.text('Personal morning dua'), findsOneWidget);
    expect(find.text('Bless me'), findsOneWidget);
  });

  testWidgets('editing custom detail refreshes content on return', (
    tester,
  ) async {
    final repository = _MemoryCustomDuaRepository([custom]);
    await _pumpDetail(
      tester,
      dua: custom,
      language: AppLanguage.english,
      repository: repository,
      favorites: _MemoryFavoritesRepository(),
    );

    await tester.tap(find.byKey(const ValueKey('custom-dua-detail-edit')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('custom-dua-meaning')),
      'Edited meaning',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('custom-dua-save')));
    await tester.tap(find.byKey(const ValueKey('custom-dua-save')));
    await tester.pumpAndSettle();

    expect(find.text('Edited meaning'), findsOneWidget);
    expect(repository.items.single.id, custom.id);
  });

  testWidgets('delete dialog cancels then confirms and clears favorite', (
    tester,
  ) async {
    final repository = _MemoryCustomDuaRepository([custom]);
    final favorites = _MemoryFavoritesRepository({'custom:one'});
    await _pumpDetail(
      tester,
      dua: custom,
      language: AppLanguage.english,
      repository: repository,
      favorites: favorites,
    );

    await tester.tap(find.byKey(const ValueKey('custom-dua-detail-delete')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.items.single.id, 'custom:one');

    await tester.tap(find.byKey(const ValueKey('custom-dua-detail-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(repository.items, isEmpty);
    expect(await favorites.load(), isEmpty);
    expect(find.byKey(const ValueKey('detail-host')), findsOneWidget);
  });
}

Future<void> _pumpDetail(
  WidgetTester tester, {
  required CustomDua dua,
  required AppLanguage language,
  required _MemoryCustomDuaRepository repository,
  required _MemoryFavoritesRepository favorites,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appLanguageProvider.overrideWithValue(language),
        customDuaRepositoryProvider.overrideWithValue(repository),
        duaFavoritesRepositoryProvider.overrideWithValue(favorites),
        customDuaIdGeneratorProvider.overrideWithValue(
          () => 'custom:generated',
        ),
      ],
      child: MaterialApp(home: _DetailHost(dua: dua)),
    ),
  );
  await tester.tap(find.byKey(const ValueKey('open-custom-dua-detail')));
  await tester.pumpAndSettle();
}

class _DetailHost extends StatelessWidget {
  const _DetailHost({required this.dua});

  final CustomDua dua;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('detail-host'),
      body: Center(
        child: FilledButton(
          key: const ValueKey('open-custom-dua-detail'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CustomDuaDetailPage(dua: dua),
            ),
          ),
          child: const Text('Open detail'),
        ),
      ),
    );
  }
}

class _MemoryCustomDuaRepository implements CustomDuaRepository {
  _MemoryCustomDuaRepository([List<CustomDua>? initial])
    : _items = {for (final dua in initial ?? const <CustomDua>[]) dua.id: dua};

  final Map<String, CustomDua> _items;

  List<CustomDua> get items => _items.values.toList();

  @override
  Future<void> delete(String id) async {
    _items.remove(id);
  }

  @override
  Future<CustomDua?> getById(String id) async => _items[id];

  @override
  Future<void> insert(CustomDua dua) async {
    _items[dua.id] = dua;
  }

  @override
  Future<List<CustomDua>> listAll() async => items;

  @override
  Future<void> update(CustomDua dua) async {
    _items[dua.id] = dua;
  }
}

class _MemoryFavoritesRepository implements DuaFavoritesRepository {
  _MemoryFavoritesRepository([Set<String>? initial]) : value = {...?initial};

  Set<String> value;

  @override
  Future<Set<String>> load() async => Set.unmodifiable(value);

  @override
  Future<void> save(Set<String> ids) async {
    value = {...ids};
  }
}
