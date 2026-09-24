# Quran Hifz V1 Foundation, Content, and Reader Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the v0.2 starter to Riverpod + Drift, establish separate canonical/user databases, build a validated bundled Quran-content pipeline, and replace the demo reader with indexed page/window loading.

**Architecture:** Keep the existing Flutter app and Hono backend, but replace manual service construction and `sqflite` with Riverpod providers and two Drift-backed SQLite lifecycles. The canonical content DB is generated offline, validated, bundled, copied atomically on first run, and queried through a reader repository.

**Tech Stack:** Flutter/Dart, flutter_riverpod, Drift/SQLite, build_runner, path_provider, existing Hono backend.

**Spec:** `docs/superpowers/specs/2026-09-04-quran-hifz-v1-architecture-design.md`

## Global Constraints

- Canonical Quran text is immutable at runtime.
- User DB migrations may not use delete-and-recreate.
- Reader must use bounded page/window loading.
- Existing Hono Quran Foundation proxy remains intact.
- Demo Quran data is removed only after canonical repository acceptance tests pass.

---

### Task 1: Migrate app composition to Riverpod and Drift

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/main.dart`
- Modify: `lib/app/quran_hifz_app.dart`
- Delete after migration: `lib/core/database/app_database.dart`
- Create: `lib/core/database/quran_content_database.dart`
- Create: `lib/core/database/user_database.dart`
- Create: `lib/core/database/database_providers.dart`
- Create: `test/core/database/user_database_migration_test.dart`
- Create: `test/app/app_bootstrap_test.dart`

**Interfaces:**
- Produces: `quranContentDatabaseProvider`, `userDatabaseProvider`, `QuranContentDatabase`, `UserDatabase`.
- Later tasks consume both DB providers via Riverpod.

- [ ] **Step 1: Add dependencies and remove direct `sqflite` dependency**

Run:

```bash
flutter pub add flutter_riverpod drift drift_flutter sqlite3_flutter_libs
flutter pub add --dev drift_dev build_runner
flutter pub remove sqflite
```

Keep `just_audio`, `path_provider`, and `path`.

- [ ] **Step 2: Write bootstrap and migration tests first**

`test/app/app_bootstrap_test.dart` must assert the root is wrapped in `ProviderScope` and can render without constructing `DemoQuranRepository` directly.

`test/core/database/user_database_migration_test.dart` must create schema v1 in a temporary DB, insert a sentinel reading-progress row, open it through the current migration path, and assert the sentinel row still exists.

Run:

```bash
flutter test test/app/app_bootstrap_test.dart test/core/database/user_database_migration_test.dart
```

Expected: FAIL because Riverpod/Drift DBs are not implemented.

- [ ] **Step 3: Implement database shells**

Create `QuranContentDatabase` and `UserDatabase` as separate Drift databases. `UserDatabase` must enable foreign keys and WAL for the mutable DB. Give `UserDatabase` an explicit `schemaVersion` and `MigrationStrategy` with versioned steps; do not include a destructive fallback.

- [ ] **Step 4: Wire ProviderScope**

`main.dart` must become conceptually:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: QuranHifzApp()));
}
```

`QuranHifzApp` becomes stateless/consumer-driven and receives services from providers rather than constructing them in `initState`.

- [ ] **Step 5: Generate Drift code and run tests**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test test/app/app_bootstrap_test.dart test/core/database/user_database_migration_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock lib test
git commit -m "refactor: establish Riverpod and Drift foundation"
```

---

### Task 2: Build deterministic Quran content importer and integrity validator

**Files:**
- Create: `tool/quran_content/build_quran_db.dart`
- Create: `tool/quran_content/models/source_records.dart`
- Create: `tool/quran_content/quran_integrity_validator.dart`
- Create: `tool/quran_content/schema.sql`
- Create: `tool/quran_content/README.md`
- Create: `test/tool/quran_content/quran_integrity_validator_test.dart`
- Create generated artifact when source data is supplied: `assets/database/quran_content.sqlite`
- Modify: `pubspec.yaml` to bundle `assets/database/quran_content.sqlite`

**Interfaces:**
- Produces: deterministic `quran_content.sqlite` and `QuranIntegrityReport validateQuranDatabase(DatabaseConnection connection)`.
- Task 3 consumes the generated DB asset.

- [ ] **Step 1: Write integrity tests with a deliberately invalid fixture**

Tests must verify rejection of:

```text
113 Surahs
6235 ayahs
duplicate verse_key
empty Arabic text
duplicate word position
translation referencing missing ayah
invalid page/Juz value
```

Also include one minimal valid fixture that passes structural validation in test mode with expected-count overrides injected into the validator.

- [ ] **Step 2: Run tests and confirm failure**

```bash
flutter test test/tool/quran_content/quran_integrity_validator_test.dart
```

Expected: FAIL because validator/importer do not exist.

- [ ] **Step 3: Implement schema and validator**

The production validator must hard-code the V1 release invariants `114` Surahs and `6236` ayahs, plus a canonical per-Surah count map stored in the validator source. Test-only constructor parameters may override totals for tiny fixtures.

The schema must provide unique/index constraints described in the spec.

- [ ] **Step 4: Implement deterministic importer**

`build_quran_db.dart` accepts explicit source paths and output path:

```bash
dart run tool/quran_content/build_quran_db.dart \
  --quran <verified-quran-source> \
  --words <verified-word-source> \
  --translation <verified-bangla-source> \
  --out assets/database/quran_content.sqlite
```

The tool must:

1. create a new temp DB;
2. import in deterministic Surah/Ayah/word order;
3. run the integrity validator;
4. compute SHA-256 of the final DB using a small Dart hashing dependency added by this task;
5. emit a machine-readable build report beside the DB;
6. atomically move the validated DB to the requested output.

Source-specific adapters must be isolated from canonical table-writing logic so a licensed/verified data source can be swapped without changing runtime repositories.

- [ ] **Step 5: Run formatter/analyzer/tests**

```bash
dart format tool test
flutter analyze
flutter test test/tool/quran_content/quran_integrity_validator_test.dart
```

Expected: PASS.

- [ ] **Step 6: Generate the production DB only from the approved verified data package**

Run the importer with the exact approved source files. Then independently run the validator command and archive its report. Do not substitute demo Quran text if the production source is unavailable.

- [ ] **Step 7: Commit**

```bash
git add tool test pubspec.yaml assets/database/quran_content.sqlite assets/database/quran_content.sqlite.report.json
git commit -m "feat: add validated bundled Quran content pipeline"
```

---

### Task 3: Copy/open bundled Quran DB safely and expose repository contracts

**Files:**
- Create: `lib/core/database/quran_content_installer.dart`
- Modify: `lib/core/database/quran_content_database.dart`
- Create: `lib/features/quran/domain/quran_page_window.dart`
- Modify: `lib/features/quran/domain/quran_repository.dart`
- Create: `lib/features/quran/data/drift_quran_repository.dart`
- Create: `lib/features/quran/application/quran_providers.dart`
- Create: `test/core/database/quran_content_installer_test.dart`
- Create: `test/features/quran/data/drift_quran_repository_test.dart`

**Interfaces:**
- `QuranRepository.listSurahs()` returns lightweight Surah summaries.
- `QuranRepository.loadPageWindow({required int page, required int translationResourceId})` returns `QuranPageWindow` with ayahs, words, translation.
- `QuranContentInstaller.ensureInstalled()` returns the verified local DB path.

- [ ] **Step 1: Write installer and repository tests**

Installer tests must simulate:

- no installed DB → atomic copy succeeds;
- existing matching content version → no rewrite;
- interrupted temp copy → old final DB retained;
- invalid replacement checksum/version → old final DB retained.

Repository tests must assert one call returns all ayahs/words for a fixture page in Quran order and does not perform one query per word.

- [ ] **Step 2: Run tests and confirm failure**

```bash
flutter test test/core/database/quran_content_installer_test.dart test/features/quran/data/drift_quran_repository_test.dart
```

- [ ] **Step 3: Implement installer**

Use app-support storage. Copy asset to `quran_content.sqlite.tmp`, verify expected packaged checksum/version, then atomically replace final path. Never overwrite a good installed DB before the new copy is verified.

- [ ] **Step 4: Implement batched repository queries**

Build reader-ready models in repository code. The UI must not issue independent queries for each word or translation.

- [ ] **Step 5: Run tests/analyze**

```bash
dart format lib test
flutter analyze
flutter test test/core/database/quran_content_installer_test.dart test/features/quran/data/drift_quran_repository_test.dart
```

- [ ] **Step 6: Commit**

```bash
git add lib test
git commit -m "feat: install and query canonical Quran database"
```

---

### Task 4: Replace demo reader with lazy page/window reader

**Files:**
- Delete after acceptance: `lib/features/quran/data/demo_quran_repository.dart`
- Modify: `lib/features/quran/presentation/quran_reader_page.dart`
- Refactor: `lib/features/quran/presentation/widgets/ayah_card.dart`
- Create: `lib/features/quran/application/reader_controller.dart`
- Create: `lib/features/quran/application/reader_state.dart`
- Create: `lib/features/quran/presentation/widgets/quran_word_view.dart`
- Create: `lib/features/quran/presentation/widgets/reader_window.dart`
- Create: `test/features/quran/application/reader_controller_test.dart`
- Create: `test/features/quran/presentation/quran_reader_page_test.dart`

**Interfaces:**
- Produces: `readerControllerProvider` and bounded `ReaderState` containing previous/current/next window IDs and loaded current data.
- Audio integration plan later consumes `QuranWordView` tap/long-press callbacks without changing repository behavior.

- [ ] **Step 1: Write reader controller/widget tests**

Tests must prove:

- opening a page loads only bounded current/adjacent windows;
- words render in canonical RTL order;
- translation toggle hides/shows translation without requerying canonical Arabic unnecessarily;
- scrolling/navigating updates persisted reading location through a repository seam;
- Al-Baqarah fixture navigation never requests the entire Surah in one repository call.

- [ ] **Step 2: Run tests and confirm failure**

```bash
flutter test test/features/quran/application/reader_controller_test.dart test/features/quran/presentation/quran_reader_page_test.dart
```

- [ ] **Step 3: Implement controller and lazy widgets**

Use Riverpod `Notifier`/`AsyncNotifier` with selective providers. Keep audio/highlight state out of the reader controller. Use lazy slivers and stable keys such as `ValueKey('ayah-2:255')` and `ValueKey('word-2:255:1')`.

- [ ] **Step 4: Remove demo repository wiring**

`QuranHifzApp` routes the reader to provider-backed content. Remove `DemoQuranRepository` only after tests pass.

- [ ] **Step 5: Profile reader**

On an Android profile build:

```bash
flutter run --profile
```

Open a long Surah, scroll continuously, change text size, and verify no whole-Surah eager build. Capture Flutter performance overlay/DevTools evidence for the release record.

- [ ] **Step 6: Run gate**

```bash
dart format lib test
flutter analyze
flutter test
```

Expected: all foundation/content/reader tests PASS.

- [ ] **Step 7: Commit**

```bash
git add lib test
git rm lib/features/quran/data/demo_quran_repository.dart
git commit -m "feat: ship lazy offline Quran reader"
```
