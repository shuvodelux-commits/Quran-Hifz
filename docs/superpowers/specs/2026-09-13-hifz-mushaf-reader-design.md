# Hifz Mushaf Reader Design

## Goal

Replace the numeric Hifz form with an Arabic-first, page-stable Mushaf-style memorization surface while preserving the existing Hifz engine, Quran data, reciter selection, offline audio, and Study reader.

## Reader behavior

- Hifz is a separate presentation mode from the continuous Study reader.
- The Hifz reader shows one canonical Quran page number at a time and filters mixed boundary pages to the selected Surah.
- Translation and inline tafsir are intentionally absent from the page surface.
- Quran words remain tappable for immediate word audio and long-pressable for the existing word-details sheet.
- The active ayah and active word use the existing shared audio state.
- When Hifz playback moves to an ayah on another Quran page in the same Surah, Hifz turns to that page automatically.

## Range selection

- Tapping an ayah-end marker selects the Hifz range.
- First tap chooses the start ayah.
- Second tap at or after start chooses the end ayah.
- A new tap after a completed range starts a new selection.
- Tapping an earlier ayah while only start is selected resets the start to the earlier ayah.
- A single selected ayah is a valid one-ayah range.

## Session controls

- Reciter is selected directly in Hifz from the bundled chapter-reciter catalog.
- Start uses the existing `HifzSessionController` and `HifzPresets.newMemorization`.
- Running sessions expose Pause and Stop.
- Paused sessions expose Resume and Stop.
- Idle/stopped/error states expose Resume saved session.
- Existing persistence/checkpoint behavior remains owned by the Hifz controller.

## Page presentation

The canonical database currently has page metadata but not canonical 15-line Mushaf line placement. V1 therefore keeps page membership exact and uses a stable Arabic page surface that scales down to the phone viewport. Exact Uthmani line geometry is a later content-data enhancement and must not be fabricated.

## Non-goals

- No changes to Study reader.
- No new audio engine.
- No cross-Surah Hifz range.
- No generated Quran text or inferred line metadata.
