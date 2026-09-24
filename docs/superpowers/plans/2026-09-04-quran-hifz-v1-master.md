# Quran Hifz V1 Master Implementation Roadmap

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver a production-ready Android-first Quran learning/Hifz V1 with verified bundled content, fast local reader, word/ayah audio, offline downloads, background playback, deterministic Hifz/revision, and upgrade-safe user data.

**Architecture:** Build a Flutter modular monolith using Riverpod and lightweight feature-based Clean Architecture. Use separate Drift/SQLite databases for canonical Quran content and mutable user state, one central audio controller, file-based audio storage, and the existing Hono/Cloudflare backend for Quran Foundation metadata/authentication only.

**Tech Stack:** Flutter/Dart, Riverpod, Drift/SQLite, just_audio, Android MediaSession integration, path_provider/filesystem storage, Hono + Cloudflare Workers.

**Spec:** `docs/superpowers/specs/2026-09-04-quran-hifz-v1-architecture-design.md`

## Global Constraints

- Android first; V1 has no video editor, account, cloud sync, AI recitation grading, classroom, or social features.
- Full verified Quran content database is bundled with the app.
- Main recitation is one file per Surah plus verified ayah/word timings.
- Dedicated word audio is separate.
- Riverpod is the state-management and DI mechanism.
- Drift + SQLite is the structured-data layer.
- Canonical content and user data have separate SQLite lifecycles.
- One central `QuranAudioController` owns semantic playback.
- Reader uses page/window loading and adjacent prefetch.
- V1 Hifz ranges stay inside one Surah.
- User DB migrations may not destroy progress.
- Quran content release requires 114 Surahs, 6236 ayahs, per-Surah count validation, unique verse keys, valid word ordering, and no empty canonical Arabic text.

---

## Execution Decomposition

This master roadmap is intentionally split into four independently reviewable implementation plans:

1. **Foundation + Content + Reader**  
   `docs/superpowers/plans/2026-09-04-quran-hifz-v1-foundation-content-reader.md`

2. **Audio + Offline Downloads + Background Playback**  
   `docs/superpowers/plans/2026-09-04-quran-hifz-v1-audio-offline-background.md`

3. **Hifz + Memorization Test + Revision + Progress**  
   `docs/superpowers/plans/2026-09-04-quran-hifz-v1-hifz-revision-progress.md`

4. **Study Tools + Settings + Production Release Hardening**  
   `docs/superpowers/plans/2026-09-04-quran-hifz-v1-study-polish-release.md`

Run them in that order. Each plan must finish with its acceptance gate green before starting the next.

## Milestone Gates

### Gate A: Trusted Offline Reader

- bundled canonical DB validated;
- fresh install copies/opens DB;
- Surah list works;
- reader window renders correct words/translation;
- long Surah does not eagerly instantiate all words;
- user DB migrations are tested.

### Gate B: Audio/Offline

- word audio tap works;
- ayah seek/clip works;
- active word timing works when verified;
- exact repeat + cancellation + auto-next work;
- downloaded audio works in airplane mode;
- screen-off playback and notification controls pass real-device testing.

### Gate C: Hifz/Revision

- deterministic same-Surah Hifz sequence works;
- state changes are persisted;
- reveal/progressive-hide tests never mutate canonical Quran rows;
- revision results schedule exact next dates through an injected clock;
- progress reads aggregated state without mutating Hifz.

### Gate D: Release

- bookmarks/notes/tafsir/search/settings stable;
- low-end profiling complete;
- upgrade preserves user data;
- six Android release flows pass;
- production-profile build has no critical analyzer/test failures.
