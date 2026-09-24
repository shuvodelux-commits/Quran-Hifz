# Quran Library, Juz Reader, Playback Panel, and Bookmarks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver a Surah/Juz/Bookmarks Quran library, multilingual fuzzy Surah search, full bounded-Juz reading, contextual reader navigation, an interactive ayah playback panel, and navigable persistent bookmarks.

**Architecture:** Keep `QuranSurahListPage` as the Quran destination and compose three focused tab views around existing Riverpod providers. Extend the read-only Quran repository with canonical Juz and batched bookmark-display queries, represent reader boundaries with explicit scope objects, and layer the new UI over the existing bounded page-window and audio-controller architecture.

**Tech Stack:** Flutter, Dart 3.12+, Material 3, Riverpod 3, Drift/SQLite, just_audio, flutter_test.

**Spec:** `docs/superpowers/specs/2026-09-15-quran-library-reader-bookmarks-design.md`

## Global Constraints

- Keep the canonical Quran database read-only and derive Juz boundaries from its `ayahs` rows.
- Preserve existing Hifz, Tafsir, translation, reading-location, word playback, and offline audio behavior.
- Search all Arabic, English, Bangla, and numeric aliases regardless of selected app language.
- Use `FontWeight.w600` for medium-bold Surah titles.
- Reader content remains windowed; never load a whole Juz into memory.
- Reuse bookmark `category` as its editable display name; do not migrate the user database.
- Follow red-green-refactor and read `superpowers:test-driven-development/writing-good-tests.md` before editing tests.
- The current workspace has no `.git` directory. Run each commit step only if executing this plan in a Git checkout; otherwise record the checkpoint in the final handoff.

## File Structure

- Create `lib/features/quran/application/surah_search.dart`: pure multilingual query normalization and ranked matching.
- Create `lib/features/quran/domain/quran_juz.dart`: canonical Juz summary.
- Create `lib/features/quran/domain/reader_scope.dart`: Surah/Juz bounds and containment rules.
- Create `lib/features/quran/presentation/widgets/quran_library_tabs.dart`: tab header and focused Surah/Juz bodies.
- Create `lib/features/quran/presentation/widgets/reader_surah_navigation.dart`: teal adjacent-Surah strip.
- Create `lib/features/quran/presentation/widgets/reader_playback_panel.dart`: reactive bottom player.
- Create `lib/features/study/domain/bookmark_display_item.dart`: hydrated bookmark display model.
- Create `lib/features/study/domain/bookmark_display_repository.dart`: batch-hydration boundary.
- Create `lib/features/study/data/drift_bookmark_display_repository.dart`: read-only canonical bookmark context query.
- Create `lib/features/study/presentation/bookmarks_view.dart`: embeddable bookmark list and actions.
- Modify `QuranRepository`, `DriftQuranRepository`, and providers for Juz summaries and batched bookmark hydration.
- Modify `QuranReaderPage`, `ReaderController`, and reader tests for scoped navigation and exact ayah launch.
- Modify the audio adapter/state/controller and their fakes/tests for duration, position, and seeking.
- Modify `AyahCard`, `StudyController`, and bookmark screens/tests for named bookmark creation and management.

---

### Task 1: Multilingual Fuzzy Surah Search

**Files:**
- Create: `lib/features/quran/application/surah_search.dart`
- Create: `test/features/quran/application/surah_search_test.dart`

**Interfaces:**
- Consumes: `QuranSurahSummary` from `features/quran/domain/quran_surah.dart`.
- Produces: `String normalizeSurahQuery(String value)` and `List<QuranSurahSummary> rankSurahMatches(Iterable<QuranSurahSummary> surahs, String query)`.

- [ ] **Step 1: Read the test-quality guide**

Run:

```bash
sed -n '1,260p' /home/shoaib/.codex/plugins/cache/openai-curated-remote/superpowers/6.3.0/skills/test-driven-development/writing-good-tests.md
```

Expected: complete guidance is read before any test is authored.

- [ ] **Step 2: Write failing normalization and ranking tests**

Add tests using two fixtures, Al-Fatihah and Al-Baqarah:

```dart
test('normalizes punctuation, Bangla digits, and Latin case', () {
  expect(normalizeSurahQuery(" AL-FA'TIHAH "), 'alfatihah');
  expect(normalizeSurahQuery('০২'), '02');
});

test('finds English aliases while Bangla labels are being displayed', () {
  expect(rankSurahMatches(surahs, 'baqar').single.number, 2);
});

test('ranks the requested shorthand al hah as Al-Fatihah', () {
  expect(rankSurahMatches(surahs, 'al hah').first.number, 1);
});

test('supports Bangla, Arabic, numeric, and small typo queries', () {
  expect(rankSurahMatches(surahs, 'ফাতিহা').first.number, 1);
  expect(rankSurahMatches(surahs, 'الفاتحة').first.number, 1);
  expect(rankSurahMatches(surahs, '২').first.number, 2);
  expect(rankSurahMatches(surahs, 'fatiah').first.number, 1);
});
```

- [ ] **Step 3: Run the tests and verify RED**

Run: `flutter test test/features/quran/application/surah_search_test.dart --reporter expanded`

Expected: compilation fails because `surah_search.dart` and its functions do not exist.

- [ ] **Step 4: Implement deterministic normalization and ranking**

Use a scored candidate internally and stable number tie-breaking:

```dart
String normalizeSurahQuery(String value) => value
    .toLowerCase()
    .replaceAllMapped(RegExp('[০-৯]'), (m) => '${'০১২৩৪৫৬৭৮৯'.indexOf(m[0]!)}')
    .replaceAll(RegExp(r"[\s\-_’']+"), '')
    .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff\u0980-\u09ff]'), '');

List<QuranSurahSummary> rankSurahMatches(
  Iterable<QuranSurahSummary> surahs,
  String query,
) {
  final normalized = normalizeSurahQuery(query);
  if (normalized.isEmpty) return List.unmodifiable(surahs);
  final scored = <({QuranSurahSummary surah, int score})>[];
  for (final surah in surahs) {
    final aliases = _aliasesFor(surah);
    final score = aliases.map((alias) => _score(normalized, alias)).reduce(math.max);
    if (score > 0) scored.add((surah: surah, score: score));
  }
  scored.sort((a, b) => b.score.compareTo(a.score) != 0
      ? b.score.compareTo(a.score)
      : a.surah.number.compareTo(b.surah.number));
  return List.unmodifiable(scored.map((entry) => entry.surah));
}
```

Implement `_aliasesFor`, transliteration folding, token initials, and bounded Levenshtein scoring locally. Exact number/alias scores `100`, prefix `80`, token/initial `70`, substring `60`, and accepted edit-distance matches `40 - distance`. Queries of length 1–3 accept only exact/prefix/token matches; longer queries accept distance `<= max(1, normalized.length ~/ 4)`.

- [ ] **Step 5: Run focused tests and refactor while green**

Run: `dart format lib/features/quran/application/surah_search.dart test/features/quran/application/surah_search_test.dart && flutter test test/features/quran/application/surah_search_test.dart --reporter expanded`

Expected: all search tests pass with no analyzer/compiler warnings.

- [ ] **Step 6: Checkpoint**

In a Git checkout:

```bash
git add lib/features/quran/application/surah_search.dart test/features/quran/application/surah_search_test.dart
git commit -m "feat: add multilingual Surah search ranking"
```

---

### Task 2: Canonical Juz Summaries and Reader Scopes

**Files:**
- Create: `lib/features/quran/domain/quran_juz.dart`
- Create: `lib/features/quran/domain/reader_scope.dart`
- Create: `test/features/quran/domain/reader_scope_test.dart`
- Modify: `lib/features/quran/domain/quran_repository.dart`
- Modify: `lib/features/quran/data/drift_quran_repository.dart`
- Modify: `lib/features/quran/application/quran_providers.dart`
- Modify: `test/features/quran/data/drift_quran_repository_test.dart`
- Modify: every test fake implementing `QuranRepository` found by `rg -l 'implements QuranRepository' test lib`

**Interfaces:**
- Produces: `QuranJuzSummary`, `ReaderScope`, `SurahReaderScope`, `JuzReaderScope`, `QuranRepository.listJuzs()`, and `quranJuzListProvider`.
- `ReaderScope` exposes `firstPage`, `lastPage`, `initialSurahNumber`, and `bool contains(QuranAyah ayah)`.

- [ ] **Step 1: Write failing scope and repository tests**

```dart
test('Juz scope contains cross-Surah ayahs only inside its Juz', () {
  const scope = JuzReaderScope(juz: juzOne);
  expect(scope.contains(ayah(surah: 1, ayah: 7, juz: 1)), isTrue);
  expect(scope.contains(ayah(surah: 2, ayah: 1, juz: 1)), isTrue);
  expect(scope.contains(ayah(surah: 2, ayah: 142, juz: 2)), isFalse);
});

test('listJuzs derives ordered canonical boundaries', () async {
  final items = await repository.listJuzs();
  expect(items.map((item) => item.number), orderedEquals([1, 2]));
  expect(items.first.firstTarget, const StudyTarget.ayah(surahNumber: 1, ayahNumber: 1));
  expect(items.first.lastTarget, const StudyTarget.ayah(surahNumber: 2, ayahNumber: 141));
});
```

Use a minimal SQLite fixture with both Juz values crossing Surah 2, and do not assert 30 items in this partial fixture. Add a separate validation test against the packaged canonical test database only if the existing test harness installs all 30 Juz values.

- [ ] **Step 2: Run focused tests and verify RED**

Run: `flutter test test/features/quran/domain/reader_scope_test.dart test/features/quran/data/drift_quran_repository_test.dart --reporter expanded`

Expected: compilation fails on missing Juz types and `listJuzs()`.

- [ ] **Step 3: Add the domain contracts**

```dart
class QuranJuzSummary {
  const QuranJuzSummary({
    required this.number,
    required this.firstTarget,
    required this.lastTarget,
    required this.firstPage,
    required this.lastPage,
    required this.startSurahNumber,
    required this.endSurahNumber,
  });
  final int number;
  final StudyTarget firstTarget;
  final StudyTarget lastTarget;
  final int firstPage;
  final int lastPage;
  final int startSurahNumber;
  final int endSurahNumber;
}

sealed class ReaderScope {
  const ReaderScope();
  int get firstPage;
  int get lastPage;
  int get initialSurahNumber;
  bool contains(QuranAyah ayah);
}
```

`SurahReaderScope.contains` compares `surahNumber`; `JuzReaderScope.contains` compares `juzNumber`.

- [ ] **Step 4: Add `listJuzs()` using canonical boundary SQL**

Add `Future<List<QuranJuzSummary>> listJuzs();` to the interface. Query grouped Juz boundaries with window-safe correlated subqueries or two ordered rows per Juz:

```sql
SELECT juz_number, MIN(page_number) AS first_page, MAX(page_number) AS last_page
FROM ayahs
GROUP BY juz_number
ORDER BY juz_number
```

For each returned Juz, fetch its first row ordered by `surah_number, ayah_number` and last row in reverse order. Validate numbers are contiguous for whatever dataset is present; production provider requires `1..30` and throws `StateError` if the canonical asset is incomplete.

- [ ] **Step 5: Update providers and repository fakes**

```dart
final quranJuzListProvider = FutureProvider<List<QuranJuzSummary>>((ref) async {
  final items = await ref.watch(quranRepositoryProvider).listJuzs();
  if (items.length != 30) throw StateError('Canonical Quran must contain 30 Juz.');
  return items;
});
```

Every fake returns fixture-appropriate Juz summaries so the interface remains compile-safe.

- [ ] **Step 6: Run tests and checkpoint**

Run: `dart format lib/features/quran/domain lib/features/quran/application/quran_providers.dart lib/features/quran/data/drift_quran_repository.dart test/features/quran/domain test/features/quran/data/drift_quran_repository_test.dart && flutter test test/features/quran/domain/reader_scope_test.dart test/features/quran/data/drift_quran_repository_test.dart --reporter expanded`

Expected: focused tests pass.

In a Git checkout:

```bash
git add lib/features/quran test/features/quran
git commit -m "feat: model canonical Juz reading scopes"
```

---

### Task 3: Surah, Juz, and Bookmarks Library Tabs

**Files:**
- Create: `lib/features/quran/presentation/widgets/quran_library_tabs.dart`
- Modify: `lib/features/quran/presentation/quran_surah_list_page.dart`
- Modify: `test/features/quran/presentation/quran_surah_list_page_test.dart`

**Interfaces:**
- Consumes: `rankSurahMatches`, `quranSurahListProvider`, and `quranJuzListProvider`. The Bookmarks tab renders a localized empty/loading seam until Task 7 replaces it with `BookmarksView`.
- Produces: tab keys `quran-tab-surah`, `quran-tab-juz`, `quran-tab-bookmarks` and callbacks opening `ReaderScope`.

- [ ] **Step 1: Replace old widget expectations with failing tab/search/style tests**

```dart
expect(find.text('সব'), findsNothing);
expect(find.text('মাক্কী'), findsNothing);
expect(find.byKey(const ValueKey('quran-tab-surah')), findsOneWidget);
expect(find.byKey(const ValueKey('quran-tab-juz')), findsOneWidget);
expect(find.byKey(const ValueKey('quran-tab-bookmarks')), findsOneWidget);

await tester.tap(find.byTooltip('Search Quran'));
await tester.enterText(find.byType(SearchBar), 'al hah');
await tester.pumpAndSettle();
expect(find.text('আল-ফাতিহা'), findsOneWidget);
expect(tester.widget<Text>(find.text('আল-ফাতিহা')).style?.fontWeight, FontWeight.w600);
```

Add a test that taps Juz 1 and verifies a `QuranReaderPage` containing both Surah 1 and Surah 2 fixture ayahs.

- [ ] **Step 2: Run the page test and verify RED**

Run: `flutter test test/features/quran/presentation/quran_surah_list_page_test.dart --reporter expanded`

Expected: tab keys are absent and old revelation filters remain.

- [ ] **Step 3: Implement the tabbed layout**

Replace `_SurahFilter` with:

```dart
enum QuranLibraryTab { surah, juz, bookmarks }
```

Build a Material tab row with localized labels and teal active underline. Keep search available on the Surah tab; pass every query to `rankSurahMatches`. Render Juz rows as `Juz <number>`, start/end Surah labels, and first verse reference. Update `_openSurah` to construct `SurahReaderScope`, and add `_openJuz` using `JuzReaderScope`.

- [ ] **Step 4: Preserve quick-scroll only where meaningful**

Mount `NumberQuickScrollRail` for Surah and Juz tabs with counts 114 and 30 respectively; omit it on Bookmarks. Ensure the content right padding is present only when the rail is mounted.

- [ ] **Step 5: Run focused tests and checkpoint**

Run: `dart format lib/features/quran/presentation test/features/quran/presentation/quran_surah_list_page_test.dart && flutter test test/features/quran/presentation/quran_surah_list_page_test.dart --reporter expanded`

Expected: all updated library tests pass.

In a Git checkout:

```bash
git add lib/features/quran/presentation test/features/quran/presentation/quran_surah_list_page_test.dart
git commit -m "feat: add Quran Surah Juz and bookmark tabs"
```

---

### Task 4: Scoped Reader and Teal Surah Navigation Strip

**Files:**
- Create: `lib/features/quran/presentation/widgets/reader_surah_navigation.dart`
- Modify: `lib/features/quran/presentation/quran_reader_page.dart`
- Modify: `lib/features/quran/application/reader_controller.dart`
- Modify: `test/features/quran/presentation/quran_reader_page_test.dart`
- Create: `test/features/quran/presentation/reader_surah_navigation_test.dart`

**Interfaces:**
- `QuranReaderPage({required ReaderScope scope, int? initialAyahNumber})` replaces its Surah-only constructor.
- `ReaderController.openPage` gains optional page bounds: `openPage(int page, {int? preferredSurahNumber, int firstPage = 1, int lastPage = 604})`; `ReaderState` stores those bounds so lazy loading cannot escape them.
- Produces callbacks for switching to adjacent `SurahReaderScope` values.

- [ ] **Step 1: Write failing reader-boundary and navigation-strip tests**

```dart
testWidgets('Juz scope crosses Surahs and excludes the next Juz', (tester) async {
  await tester.pumpWidget(app(scope: const JuzReaderScope(juz: juzOne)));
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('ayah-1:7')), findsOneWidget);
  expect(find.byKey(const ValueKey('ayah-2:1')), findsOneWidget);
  expect(find.byKey(const ValueKey('ayah-2:142')), findsNothing);
});

testWidgets('strip shows localized previous current and next Surahs', (tester) async {
  expect(find.byKey(const ValueKey('reader-surah-navigation')), findsOneWidget);
  expect(find.text('১. আল-ফাতিহা'), findsOneWidget);
  expect(find.text('২. আল-বাকারা'), findsOneWidget);
  expect(find.text('৩. আলে ইমরান'), findsOneWidget);
});
```

Also test `initialAyahNumber` scrolling and page bounds preventing loads outside a Juz.

- [ ] **Step 2: Run focused tests and verify RED**

Run: `flutter test test/features/quran/presentation/quran_reader_page_test.dart test/features/quran/presentation/reader_surah_navigation_test.dart --reporter expanded`

Expected: constructor and widget tests fail because scoped reading and strip do not exist.

- [ ] **Step 3: Generalize reader filtering and pagination**

Store `ReaderScope scope` on the page. Replace every `ayah.surahNumber == widget.surah.number` filter with `scope.contains(ayah)`. Add `firstPage` and `lastPage` to `ReaderState`; `_loadBoundedState`, `nextPage`, `previousPage`, `loadNextWindow`, and `loadPreviousWindow` use those stored bounds instead of global page limits. Resolve the active Surah from the first visible ayah rather than assuming a fixed widget Surah. Use `initialAyahNumber` to set `_jumpTargetAyah` before the initial page opens. Update every `QuranReaderPage` call site and test constructor found by `rg -l 'QuranReaderPage\(' lib test integration_test`.

- [ ] **Step 4: Implement the navigation strip**

```dart
class ReaderSurahNavigation extends StatelessWidget {
  const ReaderSurahNavigation({
    super.key,
    required this.previous,
    required this.current,
    required this.next,
    required this.language,
    required this.onSelected,
  });
  final QuranSurahSummary? previous;
  final QuranSurahSummary current;
  final QuranSurahSummary? next;
  final AppLanguage language;
  final ValueChanged<QuranSurahSummary> onSelected;
}
```

Use a teal container, left/right chevrons, equal-width side labels, a centered `FontWeight.w600` current label, safe ellipsis, and 48-pixel tap targets. Replace the existing large Surah card and retain Tafsir/download in a compact toolbar below the strip.

- [ ] **Step 5: Run reader regressions and checkpoint**

Run:

```bash
dart format lib/features/quran/application/reader_controller.dart lib/features/quran/presentation test/features/quran/presentation
flutter test test/features/quran/presentation/quran_reader_page_test.dart test/features/quran/presentation/reader_surah_navigation_test.dart test/features/quran/presentation/reader_playback_autoscroll_test.dart test/features/quran/presentation/surah_bismillah_header_test.dart --reporter expanded
```

Expected: scoped and existing reader tests pass.

In a Git checkout:

```bash
git add lib/features/quran test/features/quran
git commit -m "feat: support scoped Quran reading navigation"
```

---

### Task 5: Audio Progress and Seeking Contract

**Files:**
- Modify: `lib/core/audio/audio_player_adapter.dart`
- Modify: `lib/core/audio/just_audio_player_adapter.dart`
- Modify: `lib/features/audio/domain/quran_audio_state.dart`
- Modify: `lib/features/audio/application/quran_audio_controller.dart`
- Modify: `test/fakes/fake_audio_player_adapter.dart`
- Modify: `test/features/audio/application/quran_audio_controller_test.dart`
- Modify: `test/core/audio/just_audio_player_adapter_test.dart`

**Interfaces:**
- `AudioPlayerAdapter.durationStream` exposes loaded/clip duration.
- `QuranAudioState` gains non-null `Duration position` and `Duration duration` defaulting to zero.
- `QuranAudioController.seek(Duration position)` clamps to the active clip duration.

- [ ] **Step 1: Write failing state/controller tests**

```dart
test('publishes clip-relative position and duration during ayah playback', () async {
  fake.emitDuration(const Duration(seconds: 12));
  fake.emitPosition(const Duration(seconds: 4));
  expect(container.read(quranAudioControllerProvider).position, const Duration(seconds: 4));
  expect(container.read(quranAudioControllerProvider).duration, const Duration(seconds: 12));
});

test('seek clamps to the current clip duration', () async {
  await controller.seek(const Duration(seconds: 99));
  expect(fake.seekPositions.last, const Duration(seconds: 12));
});
```

- [ ] **Step 2: Run tests and verify RED**

Run: `flutter test test/features/audio/application/quran_audio_controller_test.dart test/core/audio/just_audio_player_adapter_test.dart --reporter expanded`

Expected: missing duration stream/state fields and seek method fail compilation.

- [ ] **Step 3: Extend adapter and state**

```dart
abstract class AudioPlayerAdapter {
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Future<void> load(String source);
  Future<void> seek(Duration position);
  Future<void> setClip({Duration? start, Duration? end});
  void play();
  Future<AudioTerminalState> waitForTerminal();
  Future<void> pause();
  Future<void> stop();
  Future<void> setSpeed(double speed);
  Future<void> dispose();
}
```

In `JustAudioPlayerAdapter`, return `_player.durationStream`. In the fake, add a broadcast duration controller and `emitDuration`. Add `position`/`duration` to all `QuranAudioState` constructors and `copyWith` without making existing callers nullable.

- [ ] **Step 4: Track progress and add safe seeking**

Subscribe to position and duration for the current session token; reset both to zero on new loads and stop. Clamp every published position to duration when duration is known. Implement:

```dart
Future<void> seek(Duration requested) async {
  if (state.mode != QuranAudioMode.ayah || state.duration <= Duration.zero) return;
  final target = requested < Duration.zero
      ? Duration.zero
      : requested > state.duration ? state.duration : requested;
  await _player.seek(target);
}
```

Cancel both subscriptions on stop/dispose and preserve the existing word-timing subscription behavior.

- [ ] **Step 5: Run all audio tests and checkpoint**

Run: `dart format lib/core/audio lib/features/audio test/fakes test/features/audio && flutter test test/features/audio test/core/audio test/features/hifz/data/quran_audio_hifz_port_test.dart --reporter expanded`

Expected: audio and Hifz adapter regressions pass.

In a Git checkout:

```bash
git add lib/core/audio lib/features/audio test/core/audio test/features/audio test/fakes test/features/hifz/data/quran_audio_hifz_port_test.dart
git commit -m "feat: expose Quran audio playback progress"
```

---

### Task 6: Reader Bottom Playback Panel

**Files:**
- Create: `lib/features/quran/presentation/widgets/reader_playback_panel.dart`
- Create: `test/features/quran/presentation/reader_playback_panel_test.dart`
- Modify: `lib/features/quran/presentation/quran_reader_page.dart`
- Modify: `lib/features/quran/application/reader_audio_actions.dart`
- Modify: `test/features/quran/application/reader_audio_actions_test.dart`

**Interfaces:**
- Consumes: `QuranAudioState`, `QuranAudioController.pause/resume/stop/seek/setSpeed`, current `ReaderScope`, Surah list, selected reciter provider.
- Produces: `ReaderPlaybackPanel` callbacks `onPrevious`, `onNext`, and `onRepeatChanged` implemented by the reader.

- [ ] **Step 1: Write failing panel widget tests**

```dart
expect(find.byKey(const ValueKey('reader-playback-panel')), findsOneWidget);
expect(find.text('Verse 2:255'), findsOneWidget);
expect(find.text('1:25'), findsOneWidget);
expect(find.byTooltip('Pause recitation'), findsOneWidget);
expect(find.byTooltip('Previous ayah'), findsOneWidget);
expect(find.byTooltip('Next ayah'), findsOneWidget);
expect(find.text('1×'), findsOneWidget);
```

Tap pause/resume, drag the slider, cycle speed, change repeat, navigate previous/next, and stop. Assert calls on a test notifier/ports rather than only icon state.

- [ ] **Step 2: Run the tests and verify RED**

Run: `flutter test test/features/quran/presentation/reader_playback_panel_test.dart --reporter expanded`

Expected: playback panel does not exist.

- [ ] **Step 3: Implement the panel visual and controller bindings**

Build a rounded teal `SafeArea` panel at `Scaffold.bottomSheet` or the bottom of the reader `Stack`. Format durations with a pure helper. Use `Slider`, central filled circular pause/resume button, previous/next buttons, speed chip, repeat button, reciter/verse labels, and a stop/dismiss button. Do not show it for idle, completed, error, word, Surah, Hifz, or revision modes.

- [ ] **Step 4: Implement scope-aware adjacent ayah playback**

Add a repository helper in `ReaderAudioActions`:

```dart
Future<QuranAyah?> adjacentAyah(
  QuranAyah current, {
  required bool forward,
  required ReaderScope scope,
}) async {
  final surahs = await _repository.listSurahs();
  final index = surahs.indexWhere((item) => item.number == current.surahNumber);
  if (index < 0) return null;
  final summary = surahs[index];
  var surahNumber = current.surahNumber;
  var ayahNumber = current.ayahNumber + (forward ? 1 : -1);
  if (forward && ayahNumber > summary.ayahCount) {
    if (index == surahs.length - 1) return null;
    surahNumber = surahs[index + 1].number;
    ayahNumber = 1;
  } else if (!forward && ayahNumber < 1) {
    if (index == 0) return null;
    final previous = surahs[index - 1];
    surahNumber = previous.number;
    ayahNumber = previous.ayahCount;
  }
  final candidate = await _repository.loadAyah(
    surahNumber: surahNumber,
    ayahNumber: ayahNumber,
    translationResourceId: _translationResourceId,
  );
  return candidate != null && scope.contains(candidate) ? candidate : null;
}
```

Use Surah metadata to roll `ayahCount → next Surah ayah 1` and `ayah 1 → previous Surah final ayah`. The reader loads/scrolls to the adjacent ayah and invokes existing `playAyah` with current repeat/speed preferences. Disable the respective button at scope boundaries.

- [ ] **Step 5: Run reader/audio tests and checkpoint**

Run:

```bash
dart format lib/features/quran test/features/quran
flutter test test/features/quran/application/reader_audio_actions_test.dart test/features/quran/presentation/reader_playback_panel_test.dart test/features/quran/presentation/quran_reader_page_test.dart test/features/quran/presentation/reader_playback_autoscroll_test.dart --reporter expanded
```

Expected: all panel and reader playback tests pass.

In a Git checkout:

```bash
git add lib/features/quran test/features/quran
git commit -m "feat: add interactive reader playback panel"
```

---

### Task 7: Fully Navigable and Manageable Bookmarks

**Files:**
- Create: `lib/features/study/domain/bookmark_display_item.dart`
- Create: `lib/features/study/domain/bookmark_display_repository.dart`
- Create: `lib/features/study/data/drift_bookmark_display_repository.dart`
- Create: `lib/features/study/presentation/bookmarks_view.dart`
- Create: `test/features/study/bookmarks_view_test.dart`
- Create: `test/features/study/data/drift_bookmark_display_repository_test.dart`
- Modify: `lib/features/study/application/study_providers.dart`
- Modify: `lib/features/study/application/study_controller.dart`
- Modify: `lib/features/study/presentation/bookmarks_page.dart`
- Modify: `lib/features/quran/presentation/widgets/ayah_card.dart`
- Modify: `lib/features/quran/presentation/quran_surah_list_page.dart`
- Modify: `test/features/study/ayah_card_study_test.dart`
- Modify: `test/features/study/study_repository_test.dart`

**Interfaces:**
- Produces: `BookmarkDisplayItem`, `BookmarkDisplayRepository.loadItems(List<Bookmark>, {required int translationResourceId})`, and reusable `BookmarksView({required ValueChanged<BookmarkDisplayItem> onOpen})`.
- `StudyController.saveBookmarkName(StudyTarget target, String name)` uses existing repository upsert.

- [ ] **Step 1: Write failing bookmark creation and view tests**

```dart
testWidgets('creating an ayah bookmark asks for and persists its name', (tester) async {
  await tester.tap(find.byTooltip('Bookmark ayah'));
  await tester.enterText(find.byKey(const ValueKey('bookmark-name-field')), 'Morning review');
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  expect(repository.bookmark?.category, 'Morning review');
});

testWidgets('bookmark list sorts renames deletes and opens exact ayah', (tester) async {
  expect(find.text('Morning review'), findsOneWidget);
  expect(find.text('২:২৫৫'), findsOneWidget);
  expect(find.textContaining('আল্লাহ'), findsOneWidget);
  await tester.tap(find.byKey(const ValueKey('bookmark-sort')));
  await tester.tap(find.byKey(const ValueKey('bookmark-sort-oldest')));
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('bookmark-1:2')), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('bookmark-menu-2:255')));
  await tester.tap(find.byKey(const ValueKey('bookmark-rename-2:255')));
  await tester.enterText(find.byKey(const ValueKey('bookmark-name-field')), 'Night review');
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  expect(find.text('Night review'), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('bookmark-2:255')));
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('ayah-2:255')), findsOneWidget);
});

testWidgets('deleting a bookmark requires confirmation', (tester) async {
  await tester.tap(find.byKey(const ValueKey('bookmark-menu-2:255')));
  await tester.tap(find.byKey(const ValueKey('bookmark-delete-2:255')));
  await tester.tap(find.byKey(const ValueKey('confirm-bookmark-delete')));
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('bookmark-2:255')), findsNothing);
});
```

Add `test/features/study/data/drift_bookmark_display_repository_test.dart` coverage proving two bookmarks are hydrated with one joined/batched SQL execution, ordered to match the input target keys, and unresolved targets yield disabled `BookmarkDisplayItem` rows rather than disappearing.

- [ ] **Step 2: Run focused tests and verify RED**

Run: `flutter test test/features/study/ayah_card_study_test.dart test/features/study/bookmarks_view_test.dart test/features/quran/data/drift_quran_repository_test.dart --reporter expanded`

Expected: name dialog, display model, and embeddable view are absent.

- [ ] **Step 3: Add batch bookmark hydration**

```dart
class BookmarkDisplayItem {
  const BookmarkDisplayItem({
    required this.bookmark,
    this.surah,
    this.ayah,
  });
  final Bookmark bookmark;
  final QuranSurahSummary? surah;
  final QuranAyah? ayah;
  bool get isAvailable => surah != null && ayah != null;
}

abstract interface class BookmarkDisplayRepository {
  Future<List<BookmarkDisplayItem>> loadItems(
    List<Bookmark> bookmarks, {
    required int translationResourceId,
  });
}
```

Implement the repository with `QuranContentDatabase`, exposed through `bookmarkDisplayRepositoryProvider`. Build a parameterized SQL `WHERE (surah_number = ? AND ayah_number = ?) OR ...` query for the small persisted bookmark set, joined to Surah and selected translation. Chunk at 200 targets to remain below SQLite bind limits and preserve input ordering in Dart. Do not query per rendered row.

- [ ] **Step 4: Add named bookmark creation**

Change the ayah action flow to first load bookmark state. Existing bookmarks are deleted directly; new bookmarks open a localized dialog. Save trimmed input or a default generated with `DateFormat`-free local formatting (`YYYY-MM-DD HH:mm`) to avoid a new dependency.

```dart
Future<StudyState> saveBookmarkName(StudyTarget target, String name) async {
  final normalized = name.trim();
  await _repository.saveBookmark(
    profileKey: profileKey,
    target: target,
    category: normalized.isEmpty ? _defaultBookmarkName(DateTime.now()) : normalized,
  );
  return load(target);
}
```

- [ ] **Step 5: Implement `BookmarksView` and standalone reuse**

The view watches bookmarks, hydrates canonical display data, supports newest/oldest sort, and renders name, localized reference, translation excerpt, date, overflow rename/delete, and a bookmark icon. `BookmarksPage` becomes a Scaffold wrapper around this view. The Quran library Bookmarks tab embeds it directly.

On row tap, construct `SurahReaderScope`, pass `initialAyahNumber`, and open `QuranReaderPage`. Unavailable rows are disabled but retain delete. Refresh/invalidate after save, rename, or delete.

- [ ] **Step 6: Run bookmark, library, and reader tests**

Run:

```bash
dart format lib/features/study lib/features/quran test/features/study test/features/quran
flutter test test/features/study test/features/quran/presentation/quran_surah_list_page_test.dart test/features/quran/presentation/quran_reader_page_test.dart --reporter expanded
```

Expected: creation, persistence, hydration, sort, rename, delete, and exact navigation tests pass.

- [ ] **Step 7: Checkpoint**

In a Git checkout:

```bash
git add lib/features/study lib/features/quran test/features/study test/features/quran
git commit -m "feat: add complete Quran bookmark workflow"
```

---

### Task 8: Full Regression and Visual Verification

**Files:**
- Modify only files required to fix failures caused by Tasks 1–7.

**Interfaces:**
- Consumes all completed feature interfaces.
- Produces a verified, formatted, analyzer-clean app build.

- [ ] **Step 1: Regenerate Drift code**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: generated database code completes successfully; no schema migration should be generated for this feature.

- [ ] **Step 2: Format and analyze**

Run: `dart format . && flutter analyze`

Expected: formatting makes no further changes on a second run and analyzer reports no issues.

- [ ] **Step 3: Run the full test suite**

Run: `flutter test --reporter expanded`

Expected: all tests pass with zero failures.

- [ ] **Step 4: Run integration smoke tests on an emulator/device**

Run:

```bash
flutter test integration_test/app_navigation_test.dart integration_test/reader_hifz_smoke_test.dart
```

Expected: navigation and reader/Hifz smoke tests pass.

- [ ] **Step 5: Perform targeted visual/interaction checks**

Verify on a compact Android viewport and one wide viewport:

```text
Bangla UI + English query "al hah" → Al-Fatihah
Juz 1 → crosses Al-Fatihah into Al-Baqarah and stops before Juz 2
reader strip → previous/current/next navigation and safe first/last Surah behavior
play ayah → bottom panel, seek, pause/resume, speed, repeat, previous/next, dismiss
bookmark → named save, Bookmarks tab display, sort, rename, reopen exact ayah, delete
dark theme → readable teal panels and controls
```

- [ ] **Step 6: Final checkpoint**

In a Git checkout:

```bash
git add .
git commit -m "test: verify Quran library reader and bookmarks"
```

If `.git` is still unavailable, do not initialize or fabricate repository history; report every verification command and result in the handoff.
