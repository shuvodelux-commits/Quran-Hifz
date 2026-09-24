import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/features/dua/application/dua_providers.dart';
import 'package:quran_hifz/features/dua/domain/custom_dua.dart';
import 'package:quran_hifz/features/dua/domain/custom_dua_repository.dart';
import 'package:quran_hifz/features/dua/domain/dua_favorites_repository.dart';
import 'package:quran_hifz/features/dua/presentation/custom_dua_form_page.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';
import 'package:quran_hifz/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('form exposes all five required fields and rejects whitespace', (
    tester,
  ) async {
    final repository = _MemoryCustomDuaRepository();
    await _pumpForm(
      tester,
      language: AppLanguage.english,
      repository: repository,
    );

    for (final key in const [
      ValueKey('custom-dua-title'),
      ValueKey('custom-dua-arabic'),
      ValueKey('custom-dua-transliteration'),
      ValueKey('custom-dua-meaning'),
      ValueKey('custom-dua-reference'),
    ]) {
      expect(find.byKey(key), findsOneWidget);
      await tester.enterText(find.byKey(key), '   ');
    }

    await tester.ensureVisible(find.byKey(const ValueKey('custom-dua-save')));
    await tester.tap(find.byKey(const ValueKey('custom-dua-save')));
    await tester.pumpAndSettle();

    expect(find.text('This field is required'), findsNWidgets(5));
    expect(repository.items, isEmpty);
  });

  testWidgets('Bangla form localizes required-field validation', (tester) async {
    await _pumpForm(
      tester,
      language: AppLanguage.bangla,
      repository: _MemoryCustomDuaRepository(),
    );

    for (final key in const [
      ValueKey('custom-dua-title'),
      ValueKey('custom-dua-arabic'),
      ValueKey('custom-dua-transliteration'),
      ValueKey('custom-dua-meaning'),
      ValueKey('custom-dua-reference'),
    ]) {
      await tester.enterText(find.byKey(key), '   ');
    }

    await tester.ensureVisible(find.byKey(const ValueKey('custom-dua-save')));
    await tester.tap(find.byKey(const ValueKey('custom-dua-save')));
    await tester.pumpAndSettle();

    expect(find.text('এই ঘরটি পূরণ করুন'), findsNWidgets(5));
  });

  testWidgets('create saves exact user content through custom controller', (
    tester,
  ) async {
    final repository = _MemoryCustomDuaRepository();
    await _pumpForm(
      tester,
      language: AppLanguage.english,
      repository: repository,
      idGenerator: () => 'custom:created',
    );

    await tester.enterText(
      find.byKey(const ValueKey('custom-dua-title')),
      'My dua',
    );
    await tester.enterText(
      find.byKey(const ValueKey('custom-dua-arabic')),
      'اللهم اغفر لي',
    );
    await tester.enterText(
      find.byKey(const ValueKey('custom-dua-transliteration')),
      'Allahummaghfir li',
    );
    await tester.enterText(
      find.byKey(const ValueKey('custom-dua-meaning')),
      'Forgive me',
    );
    await tester.enterText(
      find.byKey(const ValueKey('custom-dua-reference')),
      'My notebook',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('custom-dua-save')));
    await tester.tap(find.byKey(const ValueKey('custom-dua-save')));
    await tester.pumpAndSettle();

    final saved = repository.items.single;
    expect(saved.id, 'custom:created');
    expect(saved.title, 'My dua');
    expect(saved.arabic, 'اللهم اغفر لي');
    expect(saved.transliteration, 'Allahummaghfir li');
    expect(saved.meaning, 'Forgive me');
    expect(saved.reference, 'My notebook');
  });

  testWidgets('edit prepopulates fields and preserves id and created time', (
    tester,
  ) async {
    final createdAt = DateTime.utc(2026, 9, 24, 9);
    final existing = CustomDua(
      id: 'custom:existing',
      title: 'My dua',
      arabic: 'اللهم اغفر لي',
      transliteration: 'Allahummaghfir li',
      meaning: 'Forgive me',
      reference: 'My notebook',
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    final repository = _MemoryCustomDuaRepository([existing]);

    await _pumpForm(
      tester,
      language: AppLanguage.english,
      repository: repository,
      initial: existing,
    );

    expect(_fieldText(tester, 'custom-dua-title'), 'My dua');
    expect(_fieldText(tester, 'custom-dua-arabic'), 'اللهم اغفر لي');
    expect(
      _fieldText(tester, 'custom-dua-transliteration'),
      'Allahummaghfir li',
    );
    expect(_fieldText(tester, 'custom-dua-meaning'), 'Forgive me');
    expect(_fieldText(tester, 'custom-dua-reference'), 'My notebook');

    await tester.enterText(
      find.byKey(const ValueKey('custom-dua-meaning')),
      'Edited meaning',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('custom-dua-save')));
    await tester.tap(find.byKey(const ValueKey('custom-dua-save')));
    await tester.pumpAndSettle();

    final edited = repository.items.single;
    expect(edited.id, existing.id);
    expect(edited.createdAt, existing.createdAt);
    expect(edited.meaning, 'Edited meaning');
  });

  testWidgets('custom content stays identical in Bangla and English modes', (
    tester,
  ) async {
    final existing = CustomDua(
      id: 'custom:language',
      title: 'নিজের Title',
      arabic: 'اللهم اغفر لي',
      transliteration: 'Allahummaghfir li — নিজের লেখা',
      meaning: 'My meaning / আমার অর্থ',
      reference: 'Ref ১২৩ / 123',
      createdAt: DateTime.utc(2026, 9, 24),
      updatedAt: DateTime.utc(2026, 9, 24),
    );
    const expected = [
      'নিজের Title',
      'اللهم اغفر لي',
      'Allahummaghfir li — নিজের লেখা',
      'My meaning / আমার অর্থ',
      'Ref ১২৩ / 123',
    ];

    for (final language in [AppLanguage.bangla, AppLanguage.english]) {
      final repository = _MemoryCustomDuaRepository([existing]);
      await _pumpForm(
        tester,
        language: language,
        repository: repository,
        initial: existing,
        hostKey: ValueKey(language),
      );

      expect(
        [
          _fieldText(tester, 'custom-dua-title'),
          _fieldText(tester, 'custom-dua-arabic'),
          _fieldText(tester, 'custom-dua-transliteration'),
          _fieldText(tester, 'custom-dua-meaning'),
          _fieldText(tester, 'custom-dua-reference'),
        ],
        expected,
      );
    }
  });

  testWidgets('save failure stays on form and shows recoverable error', (
    tester,
  ) async {
    final repository = _MemoryCustomDuaRepository()..insertError = StateError('disk');
    await _pumpForm(
      tester,
      language: AppLanguage.english,
      repository: repository,
    );

    await _fillValidForm(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('custom-dua-save')));
    await tester.tap(find.byKey(const ValueKey('custom-dua-save')));
    await tester.pumpAndSettle();

    expect(find.text('Could not save Dua'), findsOneWidget);
    expect(find.byKey(const ValueKey('custom-dua-title')), findsOneWidget);
  });

  testWidgets('form fits 360px width with elevated text scaling', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpForm(
      tester,
      language: AppLanguage.english,
      repository: _MemoryCustomDuaRepository(),
      textScaler: const TextScaler.linear(1.3),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('custom-dua-save')), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpForm(
  WidgetTester tester, {
  required AppLanguage language,
  required _MemoryCustomDuaRepository repository,
  CustomDua? initial,
  String Function()? idGenerator,
  TextScaler textScaler = TextScaler.noScaling,
  Key? hostKey,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      key: hostKey,
      overrides: [
        appLanguageProvider.overrideWithValue(language),
        customDuaRepositoryProvider.overrideWithValue(repository),
        duaFavoritesRepositoryProvider.overrideWithValue(
          _MemoryFavoritesRepository(),
        ),
        customDuaIdGeneratorProvider.overrideWithValue(
          idGenerator ?? () => 'custom:generated',
        ),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: textScaler),
          child: _FormHost(initial: initial),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(const ValueKey('open-custom-dua-form')));
  await tester.pumpAndSettle();
}

String _fieldText(WidgetTester tester, String key) {
  return tester
      .widget<TextFormField>(find.byKey(ValueKey(key)))
      .controller!
      .text;
}

Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const ValueKey('custom-dua-title')),
    'My dua',
  );
  await tester.enterText(
    find.byKey(const ValueKey('custom-dua-arabic')),
    'دعاء',
  );
  await tester.enterText(
    find.byKey(const ValueKey('custom-dua-transliteration')),
    'Dua',
  );
  await tester.enterText(
    find.byKey(const ValueKey('custom-dua-meaning')),
    'Meaning',
  );
  await tester.enterText(
    find.byKey(const ValueKey('custom-dua-reference')),
    'Reference',
  );
}

class _FormHost extends StatelessWidget {
  const _FormHost({this.initial});

  final CustomDua? initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          key: const ValueKey('open-custom-dua-form'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CustomDuaFormPage(initial: initial),
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    );
  }
}

class _MemoryCustomDuaRepository implements CustomDuaRepository {
  _MemoryCustomDuaRepository([List<CustomDua>? initial])
    : _items = {for (final dua in initial ?? const <CustomDua>[]) dua.id: dua};

  final Map<String, CustomDua> _items;
  Object? insertError;

  List<CustomDua> get items => _items.values.toList();

  @override
  Future<void> delete(String id) async => _items.remove(id);

  @override
  Future<CustomDua?> getById(String id) async => _items[id];

  @override
  Future<void> insert(CustomDua dua) async {
    if (insertError case final error?) throw error;
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
  Set<String> value = {};

  @override
  Future<Set<String>> load() async => Set.unmodifiable(value);

  @override
  Future<void> save(Set<String> ids) async {
    value = {...ids};
  }
}
