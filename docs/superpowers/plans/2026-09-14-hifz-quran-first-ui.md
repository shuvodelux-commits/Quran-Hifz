# Hifz Quran-first presentation rebuild

Approved design: the user's `hifz_skin.png` and detailed four-state brief. The
current working tree is authoritative. `HifzSessionController` and
`QuranAudioController` remain the only Hifz sequence and playback authorities.

## State and file boundaries

- `HifzSessionState.status` drives reading (`idle`, `stopped`, `completed`,
  `error`) versus focus (`running`, `paused`). A modal route represents
  configuring. No Hifz playback/highlight state is added.
- `hifz_page.dart` owns Surah/page navigation, selected range and pattern,
  launches the setup/pattern/range sheets, starts/stops the existing session,
  and routes the Settings gear to the existing `SettingsPage`.
- `hifz_mushaf_surface.dart` owns only Quran page composition, range markers,
  and subtle active-ayah focus. Every word stays `QuranWordView`.
- `hifz_setup_sheet.dart` owns the compact setup rows, CTA, and summary; its
  inputs/callbacks come from `HifzPage`.
- `hifz_active_player.dart` displays current Hifz step progress and existing
  pause/resume/stop actions. It does not fabricate time seeking or skip APIs.
- `hifz_pattern_controls.dart` remains the existing progressive pattern
  editor/preview, but selection no longer starts playback.
- `quran_hifz_shell.dart` hides the global bottom bar only while Hifz focus is
  active; the destination set and navigation semantics remain unchanged.
- `SettingsPage` and shared settings providers remain the only settings UI and
  state. The gear pushes the existing page.

## TDD task 1: clean reading surface

1. Add a Hifz page widget harness using a fixture Quran repository, in-memory
   user database, and controlled audio dependencies. Assert Quran words visible,
   no setup sheet/player, compact Surah selector and Hifz tools available,
   Arabic-only presentation, and shared script/font. Run its focused test and
   confirm failure on the current large control panel.
2. Update `hifz_page.dart` to show only a compact header, Surah selector, Quran
   surface, and small tools action in reading mode. Keep word callbacks and
   existing Surah/page/range state methods. Run the focused test to green.
3. Add focused `hifz_mushaf_surface_test.dart` assertions for card-free page
   composition and markers; verify red, remove the giant page Card and heavy
   ayah framing, then verify green.

## TDD task 2: setup sheet and selection

1. Add page tests for opening/closing `Audio & Hifz`, four ordered rows, Play,
   current values, and range summary. Verify red. Add `hifz_setup_sheet.dart`
   and wire modal launch/close from `hifz_page.dart`; verify green.
2. Add tests selecting start/end from compact ayah pickers, summary update,
   end-before-start rejection, and no change to audio active-word highlight.
   Verify red; reuse `_setRangeStart`, `_setRangeEnd`, and page-follow methods
   through sheet callbacks; verify green.
3. Add tests that Pattern opens the existing sequence preview, changes a
   `HifzPatternSelection`, returns to setup without starting playback, and
   passes the exact preset to `HifzSessionConfig` on Play. Verify red. Adjust
   `hifz_pattern_controls.dart` to be selection-only and wire it in the page;
   verify green. Reciter selection uses the existing Settings route/provider.

## TDD task 3: focus, stop, and Settings

1. Add page/player tests for Play closing setup, session `running` showing a
   compact controller, Quran still visible, selected range and step/repeat
   progress visible, pause/resume/stop controls, and subtle ayah focus separate
   from shared word green. Verify red. Add `hifz_active_player.dart` and page
   layout/status transition; verify green.
2. Add stop test: the existing Hifz controller stops audio, focus clears,
   reading returns, and range/pattern persist. Verify red/green. `stopped`
   checkpoint resume remains accessible from setup.
3. Add Settings gear test for navigation to existing `SettingsPage` and script
   change returning to a coherent Hifz state. Verify red/green. Add shell test
   for nav visibility while focus is running/paused; verify red/green.

## TDD task 4: responsiveness and regression

1. Pump reading/setup/focus at 360×800, 390×844, 412×915 and a tablet size;
   assert no Flutter layout errors, reachable sheet CTA, visible Quran/player,
   and bounded content width. Verify red/green as needed.
2. Re-run Hifz presentation/session, Quran word/audio, reader, and settings
   tests. Keep direct word tap, green highlight, long press, ayah focus,
   pattern sequence and IndoPak font assertions intact.
3. Run `dart format lib test`; preserve unrelated pre-existing formatting.
   Run `flutter analyze`, `flutter test --concurrency=1`, and any relevant
   integration test. Audit changed files manually because this workspace has
   an empty `.git` placeholder and cannot produce a normal Git diff.

The existing Hifz engine has step progress but no exposed media duration or
seek/skip API. The focus controller shows honest step/repeat progress and
pause/resume/stop; it omits fabricated timestamps and next/previous controls.
