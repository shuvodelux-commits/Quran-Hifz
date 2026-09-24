# Favorite and Custom Duas Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Favorite Duas the default Dua-tab feed and add persistent user-created Duas with create, edit, delete, search, and Favorite support while keeping custom content clearly separate from the verified catalog.

**Architecture:** Keep the existing bundled `Dua` catalog immutable. Add a separate `CustomDua` domain model and Drift-backed repository, wrap verified/custom records in a small `DuaEntry` union for shared list/search/favorite presentation, and keep the existing Favorite-ID store as the single membership source. The Dua page derives one visible feed from query/category/custom-mode state, with Favorites as the zero-filter default.

**Tech Stack:** Flutter, Dart, Riverpod, Drift/SQLite, Material 3, flutter_test, build_runner/drift_dev.

**Spec:** `docs/superpowers/specs/2026-09-24-favorite-custom-duas-design.md`

## Global Constraints

- The verified bundled catalog remains read-only and unchanged by user-created content.
- Custom entries always display a visible **Custom / ব্যক্তিগত দোয়া** label and never receive Qur'an/Hadith authenticity or Sahih/Hasan metadata.
- Every custom Dua requires exactly these user-entered content fields: Title, Arabic, Transliteration, Meaning, Reference.
- Custom content is displayed exactly as entered in both Bangla and English app modes; only surrounding UI localizes.
- The main Home dashboard and Today's Ayah card remain unchanged.
- Advance `UserDatabase.schemaVersion` from **9 to 10** with an additive `custom_duas` table migration only.
- Existing Favorite IDs remain persisted by `DuaFavoritesRepository`; custom IDs use the reserved `custom:` namespace.
- No cloud sync, AI generation, automatic translation/transliteration, authenticity verification, custom categories, attachments, or favorite reordering.
- Do not add a new package dependency for ID generation; generate collision-resistant local IDs with Dart standard-library primitives.
- Follow strict TDD: every production behavior begins with a failing focused test.

## Review Focus

1. **Whitespace-only form input** — all five required fields must reject values that become empty after trimming; Task 5 adds a widget test for all five fields.
2. **Delete consistency** — deleting a favorited custom Dua must not leave a stored favorite ID, and a repository delete failure must restore the previous favorite membership; Task 4 adds both service tests.
3. **ID namespace collision** — generated custom IDs must start with `custom:`, retry on an existing generated ID, and verified bundled IDs must never use that prefix; Tasks 2 and 4 pin both sides.
4. **Mode leakage** — verified-category search must never leak custom rows, while global search includes both and Custom mode searches custom only; Tasks 4 and 7 test all three combinations.
5. **Language/layout stability** — switching Bangla/English must not rewrite custom text, and 360px + 1.3x text scaling must not overflow the updated page/form; Tasks 5 and 7 add widget coverage.

---

## File Structure

### New production files

- `lib/features/dua/domain/custom_dua.dart` — immutable custom-Dua value object plus `custom:` ID helpers.
- `lib/features/dua/domain/custom_dua_repository.dart` — CRUD abstraction for persisted custom Duas.
- `lib/features/dua/domain/dua_entry.dart` — sealed verified/custom wrapper used by shared list providers and widgets.
- `lib/features/dua/domain/custom_dua_search.dart` — custom-field search using existing Dua normalization.
- `lib/features/dua/data/drift_custom_dua_repository.dart` — Drift mapping and deterministic ordering.
- `lib/features/dua/application/custom_dua_actions.dart` — validation, ID generation/retry, create/update/delete coordination, and Favorite cleanup compensation.
- `lib/features/dua/presentation/custom_dua_form_page.dart` — create/edit form.
- `lib/features/dua/presentation/custom_dua_detail_page.dart` — custom-only detail surface and edit/delete actions.

### Modified production files

- `lib/core/database/user_database.dart` — `CustomDuas` table, schema 10 migration.
- `lib/core/database/user_database.g.dart` — regenerated Drift output.
- `lib/features/dua/application/dua_providers.dart` — custom repository/controller wiring, browse mode, combined entries, Favorite default, mixed search.
- `lib/features/dua/presentation/dua_page.dart` — Favorite default, Custom filter, Add action, entry routing.
- `lib/features/dua/presentation/widgets/dua_card.dart` — render `DuaEntry`, custom badge/reference, optional custom actions.

### New/modified tests

- `test/core/database/user_database_migration_test.dart`
- `test/features/dua/data/drift_custom_dua_repository_test.dart`
- `test/features/dua/domain/custom_dua_search_test.dart`
- `test/features/dua/data/production_dua_catalog_test.dart`
- `test/features/dua/application/custom_dua_actions_test.dart`
- `test/features/dua/application/dua_providers_test.dart`
- `test/features/dua/presentation/custom_dua_form_page_test.dart`
- `test/features/dua/presentation/custom_dua_detail_page_test.dart`
- `test/features/dua/presentation/dua_page_test.dart`

---

### Task 1: Add the custom Dua table and schema-10 migration

**Files:**
- Modify: `lib/core/database/user_database.dart:1-360`
- Regenerate: `lib/core/database/user_database.g.dart`
- Modify: `test/core/database/user_database_migration_test.dart:1-230`

**Interfaces:**
- Consumes: existing `UserDatabase`, Drift migration pattern, schema version 9.
- Produces: Drift table getter `customDuas`, generated `CustomDuaRow`, and `CustomDuasCompanion`.

- [ ] **Step 1: Write the failing v9 → v10 migration test**

Add a second test that creates a minimal v9 file with a sentinel setting, opens it through current `UserDatabase`, then proves the sentinel survives and the new table accepts a row:

```dart
test('v9 to current migration adds custom duas without losing settings', () async {
  final temp = await Directory.systemTemp.createTemp('quran_hifz_v9_');
  final file = File('${temp.path}/user_data.sqlite');

  final legacy = sqlite3.open(file.path);
  legacy.execute('''
    CREATE TABLE app_settings (
      setting_key TEXT NOT NULL PRIMARY KEY,
      setting_value TEXT NOT NULL
    );
  ''');
  legacy.execute(
    "INSERT INTO app_settings(setting_key, setting_value) "
    "VALUES ('sentinel', 'keep-me');",
  );
  legacy.execute('PRAGMA user_version = 9;');
  legacy.close();

  final db = UserDatabase.forTesting(NativeDatabase(file));
  addTearDown(() async {
    await db.close();
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  expect(await db.getSetting('sentinel'), 'keep-me');

  final created = DateTime.utc(2026, 9, 24, 12);
  await db.into(db.customDuas).insert(
    CustomDuasCompanion.insert(
      id: 'custom:migration',
      title: 'Morning',
      arabic: 'رَبِّ زِدْنِي عِلْمًا',
      transliteration: 'Rabbi zidni ilma',
      meaning: 'Increase me in knowledge',
      reference: 'User reference',
      createdAt: created,
      updatedAt: created,
    ),
  );

  final row = await db.select(db.customDuas).getSingle();
  expect(row.id, 'custom:migration');
  expect(row.title, 'Morning');
});
```

Also extend the existing v1→current test with one insert into `customDuas` after the current hifz-plan assertion, proving old installs reach schema 10.

- [ ] **Step 2: Run the migration test and verify RED**

Run:

```bash
flutter test test/core/database/user_database_migration_test.dart
```

Expected: compile/test failure because `customDuas`, `CustomDuasCompanion`, and schema-10 migration do not exist.

- [ ] **Step 3: Add the table and migration**

Add to `user_database.dart`:

```dart
@DataClassName('CustomDuaRow')
class CustomDuas extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get arabic => text()();
  TextColumn get transliteration => text()();
  TextColumn get meaning => text()();
  TextColumn get reference => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

Add `CustomDuas` to `@DriftDatabase(tables: [...])`, change:

```dart
@override
int get schemaVersion => 10;
```

and append this migration branch after the existing `from < 9` block:

```dart
if (from < 10) {
  await migrator.createTable(customDuas);
}
```

Regenerate Drift code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Run migration tests and verify GREEN**

Run:

```bash
flutter test test/core/database/user_database_migration_test.dart
```

Expected: all migration tests pass, including v9→10 and v1→current.

Then run:

```bash
git diff --check
```

Expected: no output.

- [ ] **Step 5: Commit Task 1**

```bash
git add lib/core/database/user_database.dart lib/core/database/user_database.g.dart test/core/database/user_database_migration_test.dart
git commit -m "feat: add custom dua storage schema"
```

---

### Task 2: Add the CustomDua model and Drift CRUD repository

**Files:**
- Create: `lib/features/dua/domain/custom_dua.dart`
- Create: `lib/features/dua/domain/custom_dua_repository.dart`
- Create: `lib/features/dua/data/drift_custom_dua_repository.dart`
- Create: `test/features/dua/data/drift_custom_dua_repository_test.dart`
- Modify: `test/features/dua/data/production_dua_catalog_test.dart:10-70`

**Interfaces:**
- Consumes: Task 1's `CustomDuaRow` and `customDuas` table.
- Produces:
  - `const customDuaIdPrefix = 'custom:'`
  - `bool isCustomDuaId(String id)`
  - `CustomDua`
  - `CustomDuaRepository.listAll/getById/insert/update/delete`
  - `DriftCustomDuaRepository(UserDatabase database)`

- [ ] **Step 1: Write failing repository and namespace tests**

Create `drift_custom_dua_repository_test.dart` with a file-backed round trip and deterministic-order test:

```dart
test('custom dua CRUD persists across database reopen', () async {
  final temp = await Directory.systemTemp.createTemp('custom_dua_repo_');
  final file = File('${temp.path}/user.sqlite');
  addTearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  final created = DateTime.utc(2026, 9, 24, 10);
  final firstDb = UserDatabase.forTesting(NativeDatabase(file));
  final first = DriftCustomDuaRepository(firstDb);

  final original = CustomDua(
    id: 'custom:one',
    title: 'My dua',
    arabic: 'اللهم اغفر لي',
    transliteration: 'Allahummaghfir li',
    meaning: 'O Allah, forgive me',
    reference: 'Personal note',
    createdAt: created,
    updatedAt: created,
  );

  await first.insert(original);
  await firstDb.close();

  final reopenedDb = UserDatabase.forTesting(NativeDatabase(file));
  addTearDown(reopenedDb.close);
  final reopened = DriftCustomDuaRepository(reopenedDb);

  expect(await reopened.getById('custom:one'), original);

  final edited = original.copyWith(
    title: 'Edited dua',
    updatedAt: created.add(const Duration(minutes: 5)),
  );
  await reopened.update(edited);
  expect((await reopened.getById('custom:one'))?.title, 'Edited dua');
  expect((await reopened.getById('custom:one'))?.createdAt, created);

  await reopened.delete('custom:one');
  expect(await reopened.getById('custom:one'), isNull);
});
```

Add a second test that inserts `custom:older` and `custom:newer` with different `updatedAt` values and expects `listAll().map((d) => d.id)` to equal `['custom:newer', 'custom:older']`.

Add a third test:

```dart
expect(
  () => repository.insert(nonNamespacedDua),
  throwsA(isA<ArgumentError>()),
);
```

In `production_dua_catalog_test.dart`, add inside the existing catalog loop:

```dart
expect(
  dua.id.startsWith(customDuaIdPrefix),
  isFalse,
  reason: 'verified catalog ID uses reserved custom namespace: ${dua.id}',
);
```

Import `custom_dua.dart` there.

- [ ] **Step 2: Run focused tests and verify RED**

Run:

```bash
flutter test test/features/dua/data/drift_custom_dua_repository_test.dart test/features/dua/data/production_dua_catalog_test.dart
```

Expected: compile failures because the custom domain/repository files do not exist.

- [ ] **Step 3: Implement the domain model and interface**

Create `custom_dua.dart`:

```dart
const customDuaIdPrefix = 'custom:';

bool isCustomDuaId(String id) {
  final value = id.trim();
  return value.startsWith(customDuaIdPrefix) &&
      value.length > customDuaIdPrefix.length;
}

class CustomDua {
  const CustomDua({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.reference,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String reference;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomDua copyWith({
    String? title,
    String? arabic,
    String? transliteration,
    String? meaning,
    String? reference,
    DateTime? updatedAt,
  }) => CustomDua(
    id: id,
    title: title ?? this.title,
    arabic: arabic ?? this.arabic,
    transliteration: transliteration ?? this.transliteration,
    meaning: meaning ?? this.meaning,
    reference: reference ?? this.reference,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is CustomDua &&
      other.id == id &&
      other.title == title &&
      other.arabic == arabic &&
      other.transliteration == transliteration &&
      other.meaning == meaning &&
      other.reference == reference &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    arabic,
    transliteration,
    meaning,
    reference,
    createdAt,
    updatedAt,
  );
}
```

Create `custom_dua_repository.dart`:

```dart
abstract interface class CustomDuaRepository {
  Future<List<CustomDua>> listAll();
  Future<CustomDua?> getById(String id);
  Future<void> insert(CustomDua dua);
  Future<void> update(CustomDua dua);
  Future<void> delete(String id);
}
```

- [ ] **Step 4: Implement the Drift repository**

Map rows explicitly and reject invalid IDs on insert/update:

```dart
class DriftCustomDuaRepository implements CustomDuaRepository {
  DriftCustomDuaRepository(this._database);

  final UserDatabase _database;

  @override
  Future<List<CustomDua>> listAll() async {
    final rows = await (_database.select(_database.customDuas)
          ..orderBy([
            (row) => OrderingTerm.desc(row.updatedAt),
            (row) => OrderingTerm.asc(row.id),
          ]))
        .get();
    return List.unmodifiable(rows.map(_fromRow));
  }

  @override
  Future<CustomDua?> getById(String id) async {
    final row = await (_database.select(_database.customDuas)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> insert(CustomDua dua) async {
    _validateId(dua.id);
    await _database.into(_database.customDuas).insert(_toCompanion(dua));
  }

  @override
  Future<void> update(CustomDua dua) async {
    _validateId(dua.id);
    final changed = await (_database.update(_database.customDuas)
          ..where((row) => row.id.equals(dua.id)))
        .write(_toCompanion(dua));
    if (changed != 1) throw StateError('Custom Dua not found: ${dua.id}');
  }

  @override
  Future<void> delete(String id) async {
    _validateId(id);
    await (_database.delete(_database.customDuas)
          ..where((row) => row.id.equals(id)))
        .go();
  }
}
```

Use these exact helpers:

```dart
CustomDuasCompanion _toCompanion(CustomDua dua) =>
    CustomDuasCompanion.insert(
      id: dua.id,
      title: dua.title,
      arabic: dua.arabic,
      transliteration: dua.transliteration,
      meaning: dua.meaning,
      reference: dua.reference,
      createdAt: dua.createdAt,
      updatedAt: dua.updatedAt,
    );

CustomDua _fromRow(CustomDuaRow row) => CustomDua(
  id: row.id,
  title: row.title,
  arabic: row.arabic,
  transliteration: row.transliteration,
  meaning: row.meaning,
  reference: row.reference,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
);

void _validateId(String id) {
  if (!isCustomDuaId(id)) {
    throw ArgumentError.value(id, 'id', 'Custom Dua ID must use custom:');
  }
}
```

Do not map any verified-source metadata into this repository.

- [ ] **Step 5: Run tests and commit Task 2**

Run:

```bash
flutter test test/features/dua/data/drift_custom_dua_repository_test.dart test/features/dua/data/production_dua_catalog_test.dart
```

Expected: pass.

Then:

```bash
git add lib/features/dua/domain/custom_dua.dart lib/features/dua/domain/custom_dua_repository.dart lib/features/dua/data/drift_custom_dua_repository.dart test/features/dua/data/drift_custom_dua_repository_test.dart test/features/dua/data/production_dua_catalog_test.dart
git commit -m "feat: add custom dua repository"
```

---

### Task 3: Add the verified/custom entry union and custom search

**Files:**
- Create: `lib/features/dua/domain/dua_entry.dart`
- Create: `lib/features/dua/domain/custom_dua_search.dart`
- Create: `test/features/dua/domain/custom_dua_search_test.dart`

**Interfaces:**
- Consumes: existing `Dua`, Task 2 `CustomDua`, existing `normalizeDuaQuery(String)`.
- Produces:
  - sealed `DuaEntry` with `id`
  - `VerifiedDuaEntry(Dua dua)`
  - `CustomDuaEntry(CustomDua dua)`
  - `List<CustomDua> filterCustomDuas({required List<CustomDua> duas, required String query})`

- [ ] **Step 1: Write failing search tests for all custom fields**

Use one fixture per searchable field:

```dart
test('custom search matches title Arabic transliteration meaning and reference', () {
  final duas = [
    _custom(id: 'custom:title', title: 'Morning protection'),
    _custom(id: 'custom:arabic', arabic: 'اللهم بارك لي'),
    _custom(id: 'custom:translit', transliteration: 'Allahumma barik li'),
    _custom(id: 'custom:meaning', meaning: 'Bless me in what You gave'),
    _custom(id: 'custom:reference', reference: 'Notebook ১২৩'),
  ];

  expect(_ids(filterCustomDuas(duas: duas, query: 'morning')), ['custom:title']);
  expect(_ids(filterCustomDuas(duas: duas, query: 'اللهم بارك')), ['custom:arabic']);
  expect(_ids(filterCustomDuas(duas: duas, query: 'barik')), ['custom:translit']);
  expect(_ids(filterCustomDuas(duas: duas, query: 'bless me')), ['custom:meaning']);
  expect(_ids(filterCustomDuas(duas: duas, query: '123')), ['custom:reference']);
});
```

Also assert an empty query returns all custom Duas in input order.

- [ ] **Step 2: Run the new domain test and verify RED**

Run:

```bash
flutter test test/features/dua/domain/custom_dua_search_test.dart
```

Expected: compile failure because the new files do not exist.

- [ ] **Step 3: Implement `DuaEntry`**

```dart
sealed class DuaEntry {
  const DuaEntry();
  String get id;
}

final class VerifiedDuaEntry extends DuaEntry {
  const VerifiedDuaEntry(this.dua);
  final Dua dua;

  @override
  String get id => dua.id;
}

final class CustomDuaEntry extends DuaEntry {
  const CustomDuaEntry(this.dua);
  final CustomDua dua;

  @override
  String get id => dua.id;
}
```

Do not add generic source/grade getters to this type; verified-only metadata must remain on `VerifiedDuaEntry.dua`.

- [ ] **Step 4: Implement custom search using existing normalization**

```dart
List<CustomDua> filterCustomDuas({
  required List<CustomDua> duas,
  required String query,
}) {
  final normalized = normalizeDuaQuery(query);
  if (normalized.isEmpty) return List.unmodifiable(duas);

  return List.unmodifiable(
    duas.where((dua) {
      final fields = [
        dua.title,
        dua.arabic,
        dua.transliteration,
        dua.meaning,
        dua.reference,
      ];
      return fields
          .map(normalizeDuaQuery)
          .any((field) => field.contains(normalized));
    }),
  );
}
```

- [ ] **Step 5: Run tests and commit Task 3**

Run:

```bash
flutter test test/features/dua/domain/custom_dua_search_test.dart test/features/dua/domain/dua_search_test.dart
```

Expected: pass.

Then:

```bash
git add lib/features/dua/domain/dua_entry.dart lib/features/dua/domain/custom_dua_search.dart test/features/dua/domain/custom_dua_search_test.dart
git commit -m "feat: add custom dua search model"
```

---

### Task 4: Add custom actions, ID generation, combined providers, and Favorite default

**Files:**
- Create: `lib/features/dua/application/custom_dua_actions.dart`
- Create: `test/features/dua/application/custom_dua_actions_test.dart`
- Modify: `lib/features/dua/application/dua_providers.dart:1-123`
- Modify: `test/features/dua/application/dua_providers_test.dart:1-210`

**Interfaces:**
- Consumes: Tasks 2–3 repositories/models/search, existing `DuaFavoritesRepository`.
- Produces:
  - `typedef CustomDuaIdGenerator = String Function()`
  - `CustomDuaActions.create/update/delete`
  - `customDuaRepositoryProvider`
  - `customDuaIdGeneratorProvider`
  - `customDuaActionsProvider`
  - `customDuasProvider` as an `AsyncNotifierProvider<CustomDuasController, List<CustomDua>>`
  - `duaCustomOnlyProvider`
  - `allDuaEntriesProvider`
  - `favoriteDuaEntriesProvider`
  - `visibleDuaEntriesProvider`

- [ ] **Step 1: Write failing CustomDuaActions tests**

Use in-memory fakes for custom and Favorite repositories plus injected clock/ID generator.

Pin trimming and creation:

```dart
final created = await actions.create(
  title: '  My dua  ',
  arabic: '  اللهم اغفر لي  ',
  transliteration: '  Allahummaghfir li  ',
  meaning: '  Forgive me  ',
  reference: '  Personal note  ',
);

expect(created.id, 'custom:generated');
expect(created.title, 'My dua');
expect(created.arabic, 'اللهم اغفر لي');
expect(created.createdAt, now);
expect(favorites.value, isEmpty);
```

Pin ID collision retry:

```dart
final ids = ['custom:existing', 'custom:new'];
final actions = _actions(idGenerator: () => ids.removeAt(0));
await customRepo.insert(_custom(id: 'custom:existing'));

final created = await actions.create(
  title: 'Title',
  arabic: 'دعاء',
  transliteration: 'Dua',
  meaning: 'Meaning',
  reference: 'Reference',
);
expect(created.id, 'custom:new');
```

Pin delete cleanup and rollback:

```dart
test('delete removes favorite before deleting custom row', () async {
  favorites.value = {'verified-one', 'custom:one'};
  await customRepo.insert(_custom(id: 'custom:one'));

  await actions.delete('custom:one');

  expect(await customRepo.getById('custom:one'), isNull);
  expect(favorites.value, {'verified-one'});
});

test('delete failure restores previous favorite membership', () async {
  favorites.value = {'custom:one'};
  customRepo.deleteError = StateError('write failed');

  await expectLater(actions.delete('custom:one'), throwsStateError);

  expect(favorites.value, {'custom:one'});
});
```

Also test each of the five fields throws `ArgumentError` when its trimmed value is empty.

- [ ] **Step 2: Run CustomDuaActions tests and verify RED**

Run:

```bash
flutter test test/features/dua/application/custom_dua_actions_test.dart
```

Expected: compile failure because `CustomDuaActions` does not exist.

- [ ] **Step 3: Implement CustomDuaActions**

Constructor:

```dart
typedef CustomDuaIdGenerator = String Function();

class CustomDuaActions {
  CustomDuaActions({
    required CustomDuaRepository repository,
    required DuaFavoritesRepository favorites,
    required CustomDuaIdGenerator idGenerator,
    required DateTime Function() now,
  }) : _repository = repository,
       _favorites = favorites,
       _idGenerator = idGenerator,
       _now = now;

  final CustomDuaRepository _repository;
  final DuaFavoritesRepository _favorites;
  final CustomDuaIdGenerator _idGenerator;
  final DateTime Function() _now;

  // Add the following methods inside this class.
```

Continue the same class with one shared trimming validator and the action methods:

```dart
String _requiredTrimmed(String value, String field) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError.value(value, field, '$field is required');
  }
  return trimmed;
}

Future<String> _nextUniqueId() async {
  for (var attempt = 0; attempt < 5; attempt++) {
    final id = _idGenerator();
    if (!isCustomDuaId(id)) {
      throw StateError('Custom Dua ID generator returned an invalid ID.');
    }
    if (await _repository.getById(id) == null) return id;
  }
  throw StateError('Could not generate a unique custom Dua ID.');
}

Future<CustomDua> create({
  required String title,
  required String arabic,
  required String transliteration,
  required String meaning,
  required String reference,
}) async {
  final now = _now();
  final dua = CustomDua(
    id: await _nextUniqueId(),
    title: _requiredTrimmed(title, 'title'),
    arabic: _requiredTrimmed(arabic, 'arabic'),
    transliteration: _requiredTrimmed(transliteration, 'transliteration'),
    meaning: _requiredTrimmed(meaning, 'meaning'),
    reference: _requiredTrimmed(reference, 'reference'),
    createdAt: now,
    updatedAt: now,
  );
  await _repository.insert(dua);
  return dua;
}

Future<CustomDua> update({
  required String id,
  required String title,
  required String arabic,
  required String transliteration,
  required String meaning,
  required String reference,
}) async {
  final current = await _repository.getById(id);
  if (current == null) throw StateError('Custom Dua not found: $id');

  final edited = CustomDua(
    id: current.id,
    title: _requiredTrimmed(title, 'title'),
    arabic: _requiredTrimmed(arabic, 'arabic'),
    transliteration: _requiredTrimmed(transliteration, 'transliteration'),
    meaning: _requiredTrimmed(meaning, 'meaning'),
    reference: _requiredTrimmed(reference, 'reference'),
    createdAt: current.createdAt,
    updatedAt: _now(),
  );
  await _repository.update(edited);
  return edited;
}

Future<void> delete(String id) async {
  final before = await _favorites.load();
  final wasFavorite = before.contains(id);

  if (wasFavorite) {
    await _favorites.save({...before}..remove(id));
  }

  try {
    await _repository.delete(id);
  } catch (_) {
    if (wasFavorite) await _favorites.save(before);
    rethrow;
  }
}
}
```

The final closing brace above closes `CustomDuaActions`. This ordering ensures a successful delete cannot leave a stale custom Favorite ID, while a repository-delete failure restores the previous Favorite set.

- [ ] **Step 4: Add provider tests for default Favorites and mode isolation**

Replace obsolete `duaFavoritesOnlyProvider` tests with these cases:

```dart
test('default favorite entries resolve verified and custom ids', () async {
  final container = _container(
    favorites: {'morning', 'custom:one', 'missing-id'},
    customDuas: [_custom(id: 'custom:one', title: 'Personal')],
  );
  addTearDown(container.dispose);

  final entries = await container.read(favoriteDuaEntriesProvider.future);

  expect(entries.map((entry) => entry.id), ['morning', 'custom:one']);
});

test('global search includes verified and custom entries', () async {
  final container = _container(
    customDuas: [_custom(id: 'custom:one', meaning: 'Travel protection')],
  );
  addTearDown(container.dispose);

  container.read(duaQueryProvider.notifier).setQuery('travel');
  final entries = await container.read(visibleDuaEntriesProvider.future);

  expect(entries.map((entry) => entry.id), ['travel', 'custom:one']);
});
```

Add the two mode-isolation tests explicitly:

```dart
test('verified category search excludes custom entries', () async {
  final container = _container(
    customDuas: [_custom(id: 'custom:one', meaning: 'Morning protection')],
  );
  addTearDown(container.dispose);

  container.read(duaCategoryProvider.notifier).select('daily');
  container.read(duaQueryProvider.notifier).setQuery('morning');

  final entries = await container.read(visibleDuaEntriesProvider.future);
  expect(entries, isNotEmpty);
  expect(entries.every((entry) => entry is VerifiedDuaEntry), isTrue);
});

test('custom mode search excludes verified entries', () async {
  final container = _container(
    customDuas: [_custom(id: 'custom:one', meaning: 'Morning protection')],
  );
  addTearDown(container.dispose);

  container.read(duaCustomOnlyProvider.notifier).setEnabled(true);
  container.read(duaQueryProvider.notifier).setQuery('morning');

  final entries = await container.read(visibleDuaEntriesProvider.future);
  expect(entries.map((entry) => entry.id), ['custom:one']);
  expect(entries.single, isA<CustomDuaEntry>());
});
```

- [ ] **Step 5: Implement provider/controller wiring**

In `dua_providers.dart`:

```dart
final customDuaRepositoryProvider = Provider<CustomDuaRepository>((ref) {
  return DriftCustomDuaRepository(ref.watch(userDatabaseProvider));
});

final customDuaIdGeneratorProvider = Provider<CustomDuaIdGenerator>((ref) {
  final random = Random.secure();
  return () {
    final micros = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final entropy = random.nextInt(0x7fffffff).toRadixString(36);
    return '$customDuaIdPrefix$micros:$entropy';
  };
});

final customDuaActionsProvider = Provider<CustomDuaActions>((ref) {
  return CustomDuaActions(
    repository: ref.watch(customDuaRepositoryProvider),
    favorites: ref.watch(duaFavoritesRepositoryProvider),
    idGenerator: ref.watch(customDuaIdGeneratorProvider),
    now: DateTime.now,
  );
});
```

Declare and implement the controller exactly around the action service:

```dart
final customDuasProvider =
    AsyncNotifierProvider<CustomDuasController, List<CustomDua>>(
      CustomDuasController.new,
    );

class CustomDuasController extends AsyncNotifier<List<CustomDua>> {
  @override
  Future<List<CustomDua>> build() {
    return ref.watch(customDuaRepositoryProvider).listAll();
  }

  Future<List<CustomDua>> _reload() {
    return ref.read(customDuaRepositoryProvider).listAll();
  }

  Future<CustomDua> create({
    required String title,
    required String arabic,
    required String transliteration,
    required String meaning,
    required String reference,
  }) async {
    final saved = await ref.read(customDuaActionsProvider).create(
      title: title,
      arabic: arabic,
      transliteration: transliteration,
      meaning: meaning,
      reference: reference,
    );
    state = AsyncData(await _reload());
    return saved;
  }

  Future<CustomDua> update({
    required String id,
    required String title,
    required String arabic,
    required String transliteration,
    required String meaning,
    required String reference,
  }) async {
    final saved = await ref.read(customDuaActionsProvider).update(
      id: id,
      title: title,
      arabic: arabic,
      transliteration: transliteration,
      meaning: meaning,
      reference: reference,
    );
    state = AsyncData(await _reload());
    return saved;
  }

  Future<void> delete(String id) async {
    await ref.read(customDuaActionsProvider).delete(id);
    state = AsyncData(await _reload());
    ref.invalidate(duaFavoriteIdsProvider);
  }
}
```

Remove both `duaFavoritesOnlyProvider` and `dailyDuasProvider`, plus their obsolete provider tests. Current production usage is only the Dua page default path being replaced by this feature; the pure domain helper `dailyDuas(...)` and its domain tests remain unchanged.

Declare and implement the Custom-mode provider:

```dart
final duaCustomOnlyProvider =
    NotifierProvider<DuaCustomOnlyController, bool>(
      DuaCustomOnlyController.new,
    );

class DuaCustomOnlyController extends Notifier<bool> {
  @override
  bool build() => false;

  void setEnabled(bool value) => state = value;
}
```

Implement:

```dart
final allDuaEntriesProvider = FutureProvider<List<DuaEntry>>((ref) async {
  final verified = await ref.watch(duaCatalogProvider.future);
  final custom = await ref.watch(customDuasProvider.future);
  return [
    ...verified.map(VerifiedDuaEntry.new),
    ...custom.map(CustomDuaEntry.new),
  ];
});
```

Implement the two derived providers explicitly:

```dart
final favoriteDuaEntriesProvider = FutureProvider<List<DuaEntry>>((ref) async {
  final entries = await ref.watch(allDuaEntriesProvider.future);
  final favorites = await ref.watch(duaFavoriteIdsProvider.future);
  return List.unmodifiable(
    entries.where((entry) => favorites.contains(entry.id)),
  );
});

final visibleDuaEntriesProvider = FutureProvider<List<DuaEntry>>((ref) async {
  final query = ref.watch(duaQueryProvider);
  final categoryId = ref.watch(duaCategoryProvider);
  final customOnly = ref.watch(duaCustomOnlyProvider);

  final verified = await ref.watch(duaCatalogProvider.future);
  final custom = await ref.watch(customDuasProvider.future);

  if (customOnly) {
    return filterCustomDuas(duas: custom, query: query)
        .map(CustomDuaEntry.new)
        .toList(growable: false);
  }

  if (categoryId != null) {
    final categories = await ref.watch(duaCategoriesProvider.future);
    return filterDuas(
      duas: verified,
      categories: categories,
      query: query,
      categoryId: categoryId,
    ).map(VerifiedDuaEntry.new).toList(growable: false);
  }

  if (query.trim().isNotEmpty) {
    final categories = await ref.watch(duaCategoriesProvider.future);
    final verifiedMatches = filterDuas(
      duas: verified,
      categories: categories,
      query: query,
    ).map(VerifiedDuaEntry.new);
    final customMatches =
        filterCustomDuas(duas: custom, query: query).map(CustomDuaEntry.new);
    return [...verifiedMatches, ...customMatches];
  }

  return ref.watch(favoriteDuaEntriesProvider.future);
});
```

This preserves verified-before-custom ordering and ignores unknown favorite IDs because unresolved IDs never appear in `allDuaEntriesProvider`.

- [ ] **Step 6: Run application tests and commit Task 4**

Run:

```bash
flutter test test/features/dua/application/custom_dua_actions_test.dart test/features/dua/application/dua_providers_test.dart
```

Expected: pass.

Then:

```bash
git add lib/features/dua/application/custom_dua_actions.dart lib/features/dua/application/dua_providers.dart test/features/dua/application/custom_dua_actions_test.dart test/features/dua/application/dua_providers_test.dart
git commit -m "feat: combine favorite and custom dua state"
```

---

### Task 5: Build the create/edit Custom Dua form

**Files:**
- Create: `lib/features/dua/presentation/custom_dua_form_page.dart`
- Create: `test/features/dua/presentation/custom_dua_form_page_test.dart`

**Interfaces:**
- Consumes: `customDuasProvider.notifier.create/update`, `appLanguageProvider`, optional `CustomDua initial`.
- Produces: `CustomDuaFormPage({CustomDua? initial})` that pops with the saved `CustomDua`.

- [ ] **Step 1: Write failing form-field and whitespace validation tests**

Require stable keys:

```dart
const ValueKey('custom-dua-title');
const ValueKey('custom-dua-arabic');
const ValueKey('custom-dua-transliteration');
const ValueKey('custom-dua-meaning');
const ValueKey('custom-dua-reference');
const ValueKey('custom-dua-save');
```

Use the keys in the test:

```dart
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

await tester.tap(find.byKey(const ValueKey('custom-dua-save')));
await tester.pumpAndSettle();

expect(find.text('This field is required'), findsNWidgets(5));
expect(fakeRepository.items, isEmpty);
```

Repeat the validation assertion under Bangla and expect `এই ঘরটি পূরণ করুন` five times.

- [ ] **Step 2: Write failing create/edit and language-preservation tests**

Create with exact values:

```dart
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
await tester.tap(find.byKey(const ValueKey('custom-dua-save')));
await tester.pumpAndSettle();

final saved = fakeRepository.items.single;
expect(saved.title, 'My dua');
expect(saved.arabic, 'اللهم اغفر لي');
expect(saved.transliteration, 'Allahummaghfir li');
expect(saved.meaning, 'Forgive me');
expect(saved.reference, 'My notebook');
```

For edit, pump `CustomDuaFormPage(initial: existing)`, read each `TextFormField.controller!.text`, expect the five existing values, replace Meaning with `Edited meaning`, save, and assert:

```dart
final edited = fakeRepository.items.single;
expect(edited.id, existing.id);
expect(edited.createdAt, existing.createdAt);
expect(edited.meaning, 'Edited meaning');
```

For language preservation, pump the same `existing` under Bangla and English overrides and compare the five controller values to the same literal list:

```dart
const expected = [
  'My dua',
  'اللهم اغفر لي',
  'Allahummaghfir li',
  'Forgive me',
  'My notebook',
];
```

- [ ] **Step 3: Run the form test and verify RED**

Run:

```bash
flutter test test/features/dua/presentation/custom_dua_form_page_test.dart
```

Expected: compile failure because the form page does not exist.

- [ ] **Step 4: Implement the form**

Use a `Form` with five owned `TextEditingController` instances initialized from `widget.initial`.

Validation helper:

```dart
String? _required(String? value, AppLanguage language) {
  if (value == null || value.trim().isEmpty) {
    return appText(language, 'এই ঘরটি পূরণ করুন', 'This field is required');
  }
  return null;
}
```

Use this field pattern for each controller, changing key/label/line count as specified:

```dart
TextFormField(
  key: const ValueKey('custom-dua-arabic'),
  controller: _arabicController,
  validator: (value) => _required(value, language),
  minLines: 3,
  maxLines: 6,
  textDirection: TextDirection.rtl,
  style: const TextStyle(
    fontFamily: 'Noto Naskh Arabic',
    fontSize: 22,
    height: 1.7,
  ),
  decoration: InputDecoration(
    labelText: appText(language, 'আরবি', 'Arabic'),
  ),
),
```

Use single-line Title, 2–4 lines for Transliteration and Meaning, and 2–4 lines for Reference.

Implement save exactly through the controller:

```dart
Future<void> _save(AppLanguage language) async {
  if (!_formKey.currentState!.validate() || _saving) return;
  setState(() => _saving = true);

  try {
    final notifier = ref.read(customDuasProvider.notifier);
    final saved = widget.initial == null
        ? await notifier.create(
            title: _titleController.text,
            arabic: _arabicController.text,
            transliteration: _transliterationController.text,
            meaning: _meaningController.text,
            reference: _referenceController.text,
          )
        : await notifier.update(
            id: widget.initial!.id,
            title: _titleController.text,
            arabic: _arabicController.text,
            transliteration: _transliterationController.text,
            meaning: _meaningController.text,
            reference: _referenceController.text,
          );
    if (mounted) Navigator.of(context).pop(saved);
  } catch (_) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appText(language, 'দোয়া সংরক্ষণ করা যায়নি', 'Could not save Dua'),
        ),
      ),
    );
  } finally {
    if (mounted) setState(() => _saving = false);
  }
}
```

The `custom-dua-save` button uses `onPressed: _saving ? null : () => _save(language)` so the save handler receives the same language used by the form validators and error copy.

- [ ] **Step 5: Add 360px + 1.3x text-scale form coverage**

Use:

```dart
tester.view.physicalSize = const Size(360, 780);
tester.view.devicePixelRatio = 1;
addTearDown(tester.view.resetPhysicalSize);
addTearDown(tester.view.resetDevicePixelRatio);

await _pumpForm(
  tester,
  textScaler: const TextScaler.linear(1.3),
);
await tester.scrollUntilVisible(
  find.byKey(const ValueKey('custom-dua-save')),
  300,
);
expect(tester.takeException(), isNull);
```

- [ ] **Step 6: Run tests and commit Task 5**

Run:

```bash
flutter test test/features/dua/presentation/custom_dua_form_page_test.dart
```

Expected: pass.

Then:

```bash
git add lib/features/dua/presentation/custom_dua_form_page.dart test/features/dua/presentation/custom_dua_form_page_test.dart
git commit -m "feat: add custom dua editor"
```

---

### Task 6: Render custom cards and a custom detail page safely

**Files:**
- Modify: `lib/features/dua/presentation/widgets/dua_card.dart:1-138`
- Create: `lib/features/dua/presentation/custom_dua_detail_page.dart`
- Create: `test/features/dua/presentation/custom_dua_detail_page_test.dart`
- Keep: `lib/features/dua/presentation/dua_detail_page.dart` verified-only unless a small private display widget is extracted without changing verified behavior.

**Interfaces:**
- Consumes: `DuaEntry`, `CustomDuaFormPage`, `customDuasProvider.notifier.delete`.
- Produces:
  - `DuaCard(entry: DuaEntry, ...)`
  - optional `onEdit` / `onDelete` callbacks for custom entries
  - `CustomDuaDetailPage(dua: CustomDua)`

- [ ] **Step 1: Write failing custom-detail safety tests**

Use a fixed custom fixture:

```dart
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
```

After pumping `CustomDuaDetailPage(dua: custom)`, assert:

```dart
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
expect(find.byKey(const ValueKey('custom-dua-detail-edit')), findsOneWidget);
expect(find.byKey(const ValueKey('custom-dua-detail-delete')), findsOneWidget);
```

Repeat only the badge assertion under Bangla and expect `ব্যক্তিগত দোয়া`.

- [ ] **Step 2: Write failing delete-confirmation test**

Drive both branches explicitly:

```dart
await tester.tap(
  find.byKey(const ValueKey('custom-dua-detail-delete')),
);
await tester.pumpAndSettle();
expect(find.byType(AlertDialog), findsOneWidget);

await tester.tap(find.text('Cancel'));
await tester.pumpAndSettle();
expect(fakeRepository.items.single.id, 'custom:one');

await tester.tap(
  find.byKey(const ValueKey('custom-dua-detail-delete')),
);
await tester.pumpAndSettle();
await tester.tap(find.text('Delete'));
await tester.pumpAndSettle();

expect(fakeRepository.items, isEmpty);
```

- [ ] **Step 3: Run detail tests and verify RED**

Run:

```bash
flutter test test/features/dua/presentation/custom_dua_detail_page_test.dart
```

Expected: compile failure because `CustomDuaDetailPage` does not exist.

- [ ] **Step 4: Update DuaCard to render a DuaEntry**

Change constructor to accept `DuaEntry entry` instead of `Dua dua`. Give the outer card `ValueKey('dua-card-${entry.id}')` and keep the heart key as `ValueKey('dua-favorite-${entry.id}')` so integration tests can address verified and custom rows uniformly.

Resolve display values with:

```dart
final (title, arabic, meaning) = switch (entry) {
  VerifiedDuaEntry(:final dua) => (
    language == AppLanguage.bangla ? dua.titleBangla : dua.titleEnglish,
    dua.arabic,
    language == AppLanguage.bangla
        ? dua.banglaMeaning
        : dua.englishMeaning,
  ),
  CustomDuaEntry(:final dua) => (dua.title, dua.arabic, dua.meaning),
};
```

For verified entries, preserve the existing source row exactly.

For custom entries, show `Custom / ব্যক্তিগত দোয়া` plus the user's reference. Do not call `duaSourcePrimary` or `duaSourceGrade`.

Render a compact overflow menu only for custom entries when edit/delete callbacks are provided.

- [ ] **Step 5: Implement CustomDuaDetailPage**

Use a dedicated verified-free page shape:

```dart
class CustomDuaDetailPage extends ConsumerStatefulWidget {
  const CustomDuaDetailPage({super.key, required this.dua});

  final CustomDua dua;

  @override
  ConsumerState<CustomDuaDetailPage> createState() =>
      _CustomDuaDetailPageState();
}

class _CustomDuaDetailPageState
    extends ConsumerState<CustomDuaDetailPage> {
  late CustomDua _dua;

  @override
  void initState() {
    super.initState();
    _dua = widget.dua;
  }

  Future<void> _edit() async {
    final saved = await Navigator.of(context).push<CustomDua>(
      MaterialPageRoute<CustomDua>(
        builder: (_) => CustomDuaFormPage(initial: _dua),
      ),
    );
    if (saved != null && mounted) setState(() => _dua = saved);
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_dua.title),
        actions: [
          IconButton(
            key: const ValueKey('custom-dua-detail-edit'),
            tooltip: appText(language, 'সম্পাদনা করুন', 'Edit'),
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            key: const ValueKey('custom-dua-detail-delete'),
            tooltip: appText(language, 'মুছুন', 'Delete'),
            onPressed: () => _confirmDelete(language),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          Text(appText(language, 'ব্যক্তিগত দোয়া', 'Custom')),
          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              _dua.arabic,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Noto Naskh Arabic',
                fontSize: 27,
                height: 1.8,
              ),
            ),
          ),
          _CustomTextSection(
            heading: appText(language, 'উচ্চারণ', 'Transliteration'),
            body: _dua.transliteration,
          ),
          _CustomTextSection(
            heading: appText(language, 'অর্থ', 'Meaning'),
            body: _dua.meaning,
          ),
          _CustomTextSection(
            heading: appText(language, 'সূত্র', 'Reference'),
            body: _dua.reference,
          ),
        ],
      ),
    );
  }
}
```

Implement the delete path explicitly:

```dart
Future<void> _confirmDelete(AppLanguage language) async {
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
    await ref.read(customDuasProvider.notifier).delete(_dua.id);
    if (mounted) Navigator.of(context).pop();
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
```

Do not import or display `DuaSource`, `DuaSourceType`, `HadithGrade`, `duaSourcePrimary`, or `duaSourceGrade` in this file.

- [ ] **Step 6: Run verified + custom detail tests and commit Task 6**

Run:

```bash
flutter test test/features/dua/presentation/custom_dua_detail_page_test.dart test/features/dua/presentation/dua_detail_page_test.dart
```

Expected: both pass.

Then:

```bash
git add lib/features/dua/presentation/widgets/dua_card.dart lib/features/dua/presentation/custom_dua_detail_page.dart test/features/dua/presentation/custom_dua_detail_page_test.dart
git commit -m "feat: render custom dua entries safely"
```

---

### Task 7: Replace Daily Duas with Favorite default and wire Custom mode into DuaPage

**Files:**
- Modify: `lib/features/dua/presentation/dua_page.dart:1-263`
- Modify: `test/features/dua/presentation/dua_page_test.dart:1-250`

**Interfaces:**
- Consumes: `visibleDuaEntriesProvider`, `duaCustomOnlyProvider`, `CustomDuaFormPage`, `CustomDuaDetailPage`, updated `DuaCard`.
- Produces the approved Dua-tab UX; no changes to `HomeDashboardPage`.

- [ ] **Step 1: Replace old Daily/Favorites tests with failing approved-default tests**

Default empty state:

```dart
expect(find.text('Favorite Duas'), findsOneWidget);
expect(find.text('Daily Duas'), findsNothing);
expect(find.text('Add favorite duas to show them here.'), findsOneWidget);
expect(find.byKey(const ValueKey('dua-favorites-filter')), findsNothing);
expect(find.byKey(const ValueKey('dua-custom-filter')), findsOneWidget);
```

Seed `{'wake'}` in Favorites and assert `Upon waking` is visible immediately without tapping any filter.

Add Bangla assertions for:
- `ফেভারিট দোয়া`
- `ফেভারিটে দোয়া যোগ করুন—এখানে দেখাবে।`

- [ ] **Step 2: Add failing Custom-mode and Add-action tests**

Assert:
- `custom-dua-add` app-bar action exists;
- tapping it opens the five-field form;
- `dua-custom-filter` selects Custom mode and lists a fake custom entry independent of Favorite state;
- deselecting returns to Favorite default.

Extend the test helper with a fake `CustomDuaRepository` override.

- [ ] **Step 3: Add failing mode-leakage presentation tests**

Global search query `travel` must show both verified `Travel dua` and a custom item whose meaning contains `Travel protection`.

Verified category `daily` + query `morning` must not render a custom item whose meaning contains `Morning`.

Custom mode + query must render custom matches and exclude a verified matching row.

- [ ] **Step 4: Run DuaPage tests and verify RED**

Run:

```bash
flutter test test/features/dua/presentation/dua_page_test.dart
```

Expected: failures for old Daily default, old Favorites chip, missing Custom filter/Add action, and updated `DuaCard` interface.

- [ ] **Step 5: Implement app bar and Custom filter**

Add:

```dart
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
```

Replace Favorites chip with:

```dart
FilterChip(
  key: const ValueKey('dua-custom-filter'),
  avatar: const Icon(Icons.person_outline_rounded, size: 18),
  label: Text(appText(language, 'আমার দোয়া', 'Custom Duas')),
  selected: customOnly,
  showCheckmark: false,
  onSelected: (value) {
    ref.read(duaCustomOnlyProvider.notifier).setEnabled(value);
    if (value) ref.read(duaCategoryProvider.notifier).select(null);
  },
),
```

When selecting a verified category, first set Custom mode false.

- [ ] **Step 6: Switch page data source and headings**

Replace the current `defaultMode ? dailyDuasProvider : filteredDuasProvider` branch with:

```dart
final customOnly = ref.watch(duaCustomOnlyProvider);
final favoriteIds =
    ref.watch(duaFavoriteIdsProvider).value ?? const <String>{};
final itemsState = ref.watch(visibleDuaEntriesProvider);

final defaultMode =
    query.trim().isEmpty && selectedCategory == null && !customOnly;

final heading = customOnly
    ? appText(language, 'আমার দোয়া', 'Custom Duas')
    : defaultMode
        ? appText(language, 'ফেভারিট দোয়া', 'Favorite Duas')
        : appText(language, 'দোয়ার তালিকা', 'Duas');
```

Render `heading` in the existing section-title slot.

Choose empty copy with:

```dart
final emptyMessage = defaultMode
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
```

Update `_clearFilters()` to:

```dart
void _clearFilters() {
  _searchController.clear();
  ref.read(duaQueryProvider.notifier).clear();
  ref.read(duaCategoryProvider.notifier).select(null);
  ref.read(duaCustomOnlyProvider.notifier).setEnabled(false);
}
```

This returns the page to Favorite default deterministically.

- [ ] **Step 7: Route entry types correctly**

Build each row from the entry type:

```dart
DuaCard(
  entry: entry,
  language: language,
  isFavorite: favoriteIds.contains(entry.id),
  onFavorite: () async {
    await ref.read(duaFavoriteIdsProvider.notifier).toggle(entry.id);
  },
  onTap: () => switch (entry) {
    VerifiedDuaEntry(:final dua) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DuaDetailPage(dua: dua),
        ),
      ),
    CustomDuaEntry(:final dua) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CustomDuaDetailPage(dua: dua),
        ),
      ),
  },
  onEdit: switch (entry) {
    CustomDuaEntry(:final dua) => () => Navigator.of(context).push(
        MaterialPageRoute<CustomDua>(
          builder: (_) => CustomDuaFormPage(initial: dua),
        ),
      ),
    VerifiedDuaEntry() => null,
  },
  onDelete: switch (entry) {
    CustomDuaEntry(:final dua) => () => _confirmDeleteCustom(dua),
    VerifiedDuaEntry() => null,
  },
)
```

Use the same semantics from the list card:

```dart
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
  if (confirmed == true) {
    await ref.read(customDuasProvider.notifier).delete(dua.id);
  }
}
```

Use exhaustive entry switches so a future entry type becomes a compile-time review point.

- [ ] **Step 8: Preserve responsive/theme coverage**

Keep the existing 360px + 1.3x test, now asserting the Favorite default, with `tester.takeException() == null`.

Keep the every-theme loop and inspect either a verified category chip or selected Custom chip against `appTheme(theme).colorScheme.primaryContainer`.

- [ ] **Step 9: Run presentation tests and commit Task 7**

Run:

```bash
flutter test test/features/dua/presentation/dua_page_test.dart test/features/dua/presentation/custom_dua_form_page_test.dart test/features/dua/presentation/custom_dua_detail_page_test.dart
```

Expected: pass.

Then:

```bash
git add lib/features/dua/presentation/dua_page.dart test/features/dua/presentation/dua_page_test.dart
git commit -m "feat: make favorites the default dua feed"
```

---

### Task 8: Add lifecycle regression and run release gates

**Files:**
- Modify: `test/features/dua/presentation/dua_page_test.dart`
- No production changes expected unless this regression exposes a defect.

**Interfaces:**
- Consumes complete feature from Tasks 1–7.
- Produces one high-level lifecycle regression covering the user's primary custom-Dua journey.

- [ ] **Step 1: Add the lifecycle widget test**

Write the widget test with this concrete sequence:

```dart
testWidgets(
  'custom dua can be created favorited edited and deleted from Dua tab',
  (tester) async {
    final favorites = _MemoryFavoritesRepository();
    final custom = _MemoryCustomDuaRepository();
    await _pump(
      tester,
      language: AppLanguage.english,
      favorites: favorites,
      customRepository: custom,
    );

    expect(find.text('Favorite Duas'), findsOneWidget);
    expect(find.text('Add favorite duas to show them here.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('custom-dua-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('custom-dua-title')),
      'My saved dua',
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
    await tester.tap(find.byKey(const ValueKey('custom-dua-save')));
    await tester.pumpAndSettle();

    final id = custom.items.single.id;

    await tester.tap(find.byKey(const ValueKey('dua-custom-filter')));
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('dua-card-$id')), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('dua-favorite-$id')));
    await tester.pumpAndSettle();
    expect(await favorites.load(), contains(id));

    await tester.tap(find.byKey(const ValueKey('dua-custom-filter')));
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('dua-card-$id')), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('dua-card-$id')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('custom-dua-detail-edit')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('custom-dua-meaning')),
      'Edited meaning',
    );
    await tester.tap(find.byKey(const ValueKey('custom-dua-save')));
    await tester.pumpAndSettle();

    expect(find.text('Edited meaning'), findsOneWidget);
    expect(await favorites.load(), contains(id));

    await tester.tap(
      find.byKey(const ValueKey('custom-dua-detail-delete')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byKey(ValueKey('dua-card-$id')), findsNothing);
    expect(await favorites.load(), isNot(contains(id)));
    expect(custom.items, isEmpty);
  },
);
```

The test helper overrides both `customDuaRepositoryProvider` and `customDuaIdGeneratorProvider` so IDs are deterministic and no real database is required for this UI lifecycle test.

- [ ] **Step 2: Run the lifecycle test and fix only defects it reveals**

Run:

```bash
flutter test test/features/dua/presentation/dua_page_test.dart --plain-name "custom dua can be created favorited edited and deleted from Dua tab"
```

Expected: pass after any minimal integration correction. Do not broaden feature scope.

- [ ] **Step 3: Run all focused Dua + migration tests**

Run:

```bash
flutter test \
  test/core/database/user_database_migration_test.dart \
  test/features/dua/domain/dua_search_test.dart \
  test/features/dua/domain/custom_dua_search_test.dart \
  test/features/dua/data/bundled_dua_repository_test.dart \
  test/features/dua/data/production_dua_catalog_test.dart \
  test/features/dua/data/user_database_dua_favorites_repository_test.dart \
  test/features/dua/data/drift_custom_dua_repository_test.dart \
  test/features/dua/application/custom_dua_actions_test.dart \
  test/features/dua/application/dua_providers_test.dart \
  test/features/dua/presentation/dua_detail_page_test.dart \
  test/features/dua/presentation/custom_dua_detail_page_test.dart \
  test/features/dua/presentation/custom_dua_form_page_test.dart \
  test/features/dua/presentation/dua_page_test.dart
```

Expected: all pass.

- [ ] **Step 4: Run static analysis and complete test suite**

Run:

```bash
flutter analyze
flutter test
```

Expected: `No issues found!` and zero test failures.

- [ ] **Step 5: Build, install, and launch debug APK**

Run:

```bash
flutter build apk --debug
adb connect 192.168.10.9:5555
adb -s 192.168.10.9:5555 install -r -t build/app/outputs/flutter-apk/app-debug.apk
adb -s 192.168.10.9:5555 shell monkey \
  -p com.quranhifz.app.debug \
  -c android.intent.category.LAUNCHER 1
```

Expected: APK builds, install says `Success`, and the app launches.

- [ ] **Step 6: Real-device visual verification**

On OPPO CPH2179 verify:
- Dua opens to Favorite Duas, not Daily Duas;
- empty guidance is correct;
- verified Favorite appears immediately in default feed;
- Add Dua form accepts paste/input for all five fields;
- saved custom content is unchanged between Bangla and English modes;
- Custom/Personal label is visible;
- custom Favorite joins verified Favorites;
- edit preserves Favorite membership;
- delete confirmation removes the item from Custom/Search/Favorites;
- main Home dashboard still shows Today's Ayah unchanged.

Capture screenshots of Favorite default, Custom list, and custom detail after edit.

- [ ] **Step 7: Final diff and final task commit**

Run:

```bash
git diff --check
git status --short
git diff --name-only
```

Expected: only files from this plan are modified.

If Task 8 added or changed test/code after Task 7, commit those exact files:

```bash
git add test/features/dua/presentation/dua_page_test.dart
git add lib/features/dua
git commit -m "test: cover custom dua lifecycle"
```

Do not stage unrelated files. If no Task-8 changes remain after earlier commits, skip the extra commit and report the clean tree.

---

## Completion Checklist

Before claiming completion, verify from fresh command output:

- [ ] `UserDatabase.schemaVersion == 10`.
- [ ] v9→10 migration passes and preserves existing settings.
- [ ] Existing v1→current migration still passes.
- [ ] Verified production catalog remains 100+ entries and has no `custom:` IDs.
- [ ] Custom repository CRUD persists across database reopen.
- [ ] All five custom fields reject whitespace-only input.
- [ ] Custom ID collision retry is tested.
- [ ] Delete cleanup and delete-failure Favorite restoration are tested.
- [ ] Default Dua feed is Favorite Duas.
- [ ] Global search includes verified + custom.
- [ ] Verified category search excludes custom.
- [ ] Custom mode search excludes verified.
- [ ] Custom content is identical across Bangla/English modes.
- [ ] Custom entries never show verified source/grading UI.
- [ ] 360px + 1.3x text scaling has no overflow.
- [ ] `flutter analyze` passes.
- [ ] Full `flutter test` passes.
- [ ] Debug APK builds.
- [ ] APK installs and launches on OPPO CPH2179.
- [ ] Real-device create/favorite/edit/delete is visually verified.
- [ ] Main Home dashboard remains unchanged.
- [ ] `git diff --check` is clean.
