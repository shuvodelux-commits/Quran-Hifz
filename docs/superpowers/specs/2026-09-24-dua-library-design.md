# Dua Library and Navigation Replacement Design

## Goal

Replace the existing Salat Tracker bottom-navigation destination with a fully offline Dua library containing 100+ carefully verified Qur'anic and Sahih/Hasan hadith supplications. The library should support a natural morning-to-night daily flow, category browsing, Bangla/English search, full reading details, and persistent Favorites while preserving the app's existing theme and localization behavior.

The Salat Tracker is removed from the user-facing app. Prayer schedules, current-prayer information, prohibited-time calculations, and the prayer calendar remain unchanged.

## Product Decisions

- Bottom navigation becomes: Home, Dua, Quran, Calendar, More.
- The current Prayer/Salat Tracker tab is removed and replaced by Dua.
- The Salat Tracker itself is removed from the user-facing app rather than moved elsewhere.
- Existing tracker data may remain inert in old user databases; no destructive migration is required solely to delete historical tracker rows.
- Home prayer information remains available, but any action that previously opened the Salat Tracker is removed rather than redirected to another tracker screen.
- Dua v1 is fully offline and contains no audio.
- Dua v1 includes Favorites.
- The bundled catalog contains at least 100 verified entries.
- Accepted religious sources are limited to:
  - Qur'anic supplications with exact Surah and Ayah references.
  - Hadith supplications whose grading is Sahih or Hasan.
- Weak, fabricated, unsourced, or popularity-only duas are excluded.
- A requested topic is omitted if no qualifying source can be established. The catalog must not weaken the source standard to fill a category.
- “Munajat” is a curated grouping of authentic Qur'anic and Sahih/Hasan supplications suitable for personal supplication; it is not a separately invented prayer text.
- Bangla mode shows Arabic, Bangla pronunciation, Bangla meaning, and source/reference.
- English mode shows Arabic, English transliteration, English meaning, and source/reference.
- Content corrections must be possible without changing widget code.

## User Experience

### Bottom Navigation

The five destinations are:

1. Home
2. Dua
3. Quran
4. Calendar
5. More

The Dua destination uses an appropriate supplication icon and localizes its label as “দোয়া” in Bangla and “Dua” in English.

### Dua Landing Page

The main Dua page is designed as a daily-use surface rather than a flat reference list.

Top area:

- localized page title;
- search field;
- Favorites shortcut/filter.

Primary content:

- a “Daily Duas” section ordered from waking through sleep;
- a compact horizontal category selector;
- category-filtered results below;
- a Favorites view using the same card component.

The daily order is editorial metadata in the catalog, not inferred from category names. Entries without a daily-order position remain available through categories and search.

### Daily Journey

The initial daily journey should cover qualifying authentic duas in a practical sequence such as:

- waking;
- bathroom/toilet etiquette;
- wudu;
- clothing;
- entering/leaving home;
- mosque;
- Salah-related supplications and adhkar;
- food and drink;
- work/travel/vehicle;
- morning and evening protection;
- family and children;
- marital intimacy;
- illness and healing;
- weather;
- moon sighting;
- forgiveness and repentance;
- debt and provision;
- sleep and night.

The sequence is driven by authentic content availability. No category or step is populated with a weak narration merely to make the journey look complete.

### Categories

The catalog supports multiple category memberships per Dua. Initial categories include:

- Daily Routine
- Salah
- Mosque
- Morning & Evening
- Protection & Distress
- Food & Drink
- Travel & Vehicle
- Work & Market
- Family & Children
- Marital Intimacy
- Illness & Healing
- Rain, Wind & Weather
- Moon Sighting
- Janazah
- Forgiveness & Tawbah
- Rizq & Debt
- Qur'anic Duas
- Munajat
- Sleep & Night

Category labels are localized. If a requested topic such as a market-specific dua has no source meeting the Sahih/Hasan rule, the category may contain broader authenticated work/provision supplications or remain without that specific item. The UI must not claim an unsupported “market dua.”

### Dua Cards

A compact list card shows:

- localized Dua title;
- short Arabic preview;
- short localized meaning preview;
- concise source label;
- Favorite toggle.

Cards use the existing theme system, compact spacing, and accessible touch targets. No hard-coded blue/green/pink colors are used.

### Dua Detail Page

The detail view prioritizes readability.

Bangla mode order:

1. Arabic
2. বাংলা উচ্চারণ
3. বাংলা অর্থ
4. সূত্র / রেফারেন্স
5. Hadith grading details when applicable

English mode order:

1. Arabic
2. Transliteration
3. English meaning
4. Source/reference
5. Hadith grading details when applicable

The Arabic text uses an Arabic-capable font already bundled by the app. Regular UI text follows the current app typography. The page supports long text and Android text scaling without clipping.

## Architecture

Create a self-contained feature under:

`lib/features/dua/`

Suggested structure:

- `domain/dua.dart`
- `domain/dua_repository.dart`
- `data/bundled_dua_repository.dart`
- `application/dua_providers.dart`
- `presentation/dua_page.dart`
- `presentation/dua_detail_page.dart`
- `presentation/widgets/dua_card.dart`
- `presentation/widgets/dua_category_filter.dart`

Bundled content lives under:

- `assets/dua/duas.json`

The content catalog is read-only app content. User Favorite state lives separately in the existing user-data layer.

### Dua Domain Model

A Dua entry has a stable, human-readable ID and immutable content fields. A practical model contains:

- `id`
- `titleBangla`
- `titleEnglish`
- `arabic`
- `banglaPronunciation`
- `banglaMeaning`
- `englishTransliteration`
- `englishMeaning`
- `categoryIds`
- `tagsBangla`
- `tagsEnglish`
- optional `dailyOrder`
- optional short usage/context note
- one or more verified source records

A source record distinguishes Qur'an from Hadith.

Qur'an source metadata includes:

- source type;
- Surah number/name;
- Ayah number or bounded Ayah range.

Hadith source metadata includes:

- source type;
- collection;
- canonical reference identifier/number;
- grade: Sahih or Hasan;
- grading authority or edition/source used for the grade when needed.

Multiple sources are allowed where the same wording is authenticated through more than one report.

### Stable IDs

Stable IDs must not depend on list position. Favorites store only the Dua ID. Catalog reordering, corrected translations, or added source metadata therefore do not invalidate user Favorites.

IDs are never silently reused for a different Dua.

### Repository

`DuaRepository` exposes read-only operations such as:

- list all Duas;
- load by stable ID;
- list categories;
- search/filter locally.

`BundledDuaRepository` loads and validates the packaged JSON once, then serves immutable in-memory records. The page does not parse assets directly.

### Search

Search is fully offline and language-independent. It matches normalized:

- Bangla title;
- Bangla pronunciation;
- Bangla meaning;
- English title;
- English transliteration;
- English meaning;
- category labels/IDs;
- tags;
- source reference text where useful.

Normalization should include case folding for Latin text, whitespace/punctuation normalization, and Bangla/ASCII digit equivalence. Arabic search may be supported where straightforward, but v1 correctness is centered on Bangla and English discovery.

Search results preserve deterministic catalog order unless a clear exact/prefix match should rank first.

### Favorites

Favorites are user data, not content data.

Add a minimal persistent Favorite store keyed by Dua ID in the existing user database/repository layer. A dedicated `dua_favorites` table is preferred if the current Drift database pattern supports a small additive migration cleanly.

The table only needs the stable Dua ID and a creation timestamp. It must not duplicate Arabic or translation content.

Behavior:

- tapping the Favorite action adds/removes the ID;
- Favorites survive app restart;
- missing catalog IDs are ignored safely if content is later retired;
- duplicate Favorite rows are impossible.

If implementation inspection shows that the existing user-data abstraction has a simpler established key/value persistence pattern that is equally durable and testable, the implementation plan may use that pattern instead, but content and user state remain separated.

## Content Verification Pipeline

Religious content accuracy is a release requirement, not editorial polish.

Every catalog record must pass these checks before inclusion:

1. Arabic wording is verified against a reliable primary or authoritative digital source.
2. Qur'anic entries identify the exact Surah/Ayah.
3. Hadith entries identify the collection/reference.
4. Hadith grading is Sahih or Hasan.
5. The grade source/authority is recorded when the collection itself does not make the status self-evident.
6. Bangla pronunciation is app-authored/reviewed for usability and does not intentionally replace the Arabic.
7. Bangla and English meanings are concise, faithful renderings; they do not add unsupported promises or commentary.
8. Duplicate content is represented once and assigned multiple categories/tags where appropriate.
9. Variants with materially different wording are separate entries only when each variant independently meets the source rule.
10. No entry uses marketing labels such as “guaranteed,” “most powerful,” or “100% effective.”

The implementation phase should use current, authoritative web/library references to verify catalog content. The catalog must retain enough provenance to re-audit every entry later.

### Source Policy for Commonly Circulated Duas

Some widely shared supplications are transmitted through weak or disputed reports. Popularity does not override the agreed source rule.

Examples such as market-specific supplications, special-purpose “powerful munajat” formulas, or circulating protection formulas are included only when the exact entry has a qualifying Qur'anic or Sahih/Hasan basis. Otherwise they are omitted or replaced only by a different authentic supplication whose meaning is accurately labeled.

## Salat Tracker Removal

The tracker feature is removed from the active product surface:

- `AppDestination.prayer` becomes the Dua destination.
- `QuranHifzShell` renders `DuaPage` for the second destination.
- the bottom label becomes Dua/দোয়া.
- Home no longer navigates to `PrayerTrackerPage`.
- tracker-specific page/provider/repository code that becomes unreachable should be deleted when it has no other consumers.
- prayer schedule calculation, mosque times, current prayer, fasting information, prohibited-time display, and Calendar remain.
- old tracker database tables/rows may remain for backward compatibility; no destructive migration is required.

The implementation must use reference searches before deleting tracker code so shared prayer-schedule code is not removed accidentally.

## State and Data Flow

1. The app starts with the Dua catalog available from bundled assets.
2. `DuaPage` watches catalog, query, category, and Favorite state through Riverpod providers.
3. Search/category filtering runs locally over the immutable catalog.
4. Tapping a card opens the detail page with the stable Dua ID/record.
5. Favorite changes write only the stable ID to user storage and update the visible list immediately.
6. App language determines title, pronunciation/transliteration, meaning, labels, and category names.
7. App theme determines all colors and Material surface behavior.

No network request is required to browse, search, read, or Favorite a Dua.

## Error and Empty States

- A malformed bundled catalog is treated as a development/release validation failure. Production UI should not silently present partially parsed religious content.
- If asset loading unexpectedly fails, the page shows a localized retry/error state rather than fabricated fallback text.
- Search with no matches shows a localized empty state and clear-search action.
- Favorites with no entries explains how to Favorite a Dua.
- A stored Favorite ID missing from the current catalog is ignored and may be cleaned up lazily.
- Unsupported/weak source material is excluded rather than shown with a warning badge.

## Theming and Accessibility

- The Dua module uses `Theme.of(context).colorScheme`; no category/card uses hard-coded theme colors.
- Light, green, women, and dark themes must all remain readable.
- Arabic uses appropriate RTL directionality.
- Bangla and English UI follow the existing app language selection.
- Touch targets remain at least 44-48 logical pixels where interactive.
- Search, Favorite, back, and category controls have semantic labels/tooltips.
- Long Arabic and translation text wraps naturally.
- 360px-wide Android layouts and increased system text scale must not overflow.
- Favorite state is conveyed by icon plus semantics, not color alone.

## Testing

Implementation follows test-driven development.

### Catalog Validation Tests

Tests prove:

- at least 100 entries are bundled;
- every ID is unique and stable-format;
- every entry has non-empty Arabic;
- every entry has Bangla pronunciation and meaning;
- every entry has English transliteration and meaning;
- every entry has at least one category;
- every entry has at least one valid source;
- Qur'an sources have Surah/Ayah metadata;
- Hadith sources are only Sahih or Hasan and include collection/reference;
- daily-order values are unique where required or deterministically ordered;
- all referenced category IDs exist;
- no Favorite/user fields are embedded in catalog content.

### Repository and Search Tests

Tests cover:

- JSON parsing;
- stable-ID lookup;
- Bangla title/meaning search;
- Bangla pronunciation search;
- English title/meaning/transliteration search;
- category filtering;
- Favorites-only filtering;
- deterministic combined search/category behavior.

### Favorites Tests

Tests cover:

- add;
- remove;
- duplicate prevention;
- persistence across repository/database recreation;
- missing catalog IDs;
- ordering of Favorites.

### Widget and Navigation Tests

Tests cover:

- bottom navigation shows Home, Dua, Quran, Calendar, More;
- Salat/Prayer destination is absent;
- tapping Dua opens `DuaPage`;
- Home no longer opens the Salat Tracker;
- Daily Duas render in configured order;
- categories filter correctly;
- search works in Bangla and English;
- Favorite toggle updates immediately;
- detail page renders the correct Bangla field order;
- detail page renders the correct English field order;
- source and grade metadata are visible;
- empty search and empty Favorites states;
- light, green, women, and dark themes;
- 360px layout and elevated text scaling.

### Regression Verification

Final verification includes:

- `dart format`;
- focused red/green tests while implementing;
- complete `flutter test`;
- `flutter analyze`;
- debug APK build;
- installation on the connected Android device;
- manual visual pass of Dua landing, search, Favorites, detail page, all four themes, and the remaining Home/Quran/Calendar/More destinations.

## Content Delivery Strategy

The first implementation ships a reviewed 100+ entry catalog as part of the feature, not placeholder lorem ipsum or unsourced sample Duas.

To keep review manageable, content can be assembled in batches during implementation, but the feature is not considered complete until the catalog validation test confirms at least 100 qualifying records and the provenance review is complete.

The UI and domain layer should be implemented against small test fixtures first; production catalog data is then added through the same validated schema.

## Out of Scope for v1

- Dua audio or recitation downloads.
- Read/checklist progress tracking.
- Daily streaks or reminders.
- Cloud sync for Favorites.
- User-created/custom Duas.
- Sharing images/cards.
- Remote catalog updates.
- Weak-hadith opt-in mode.
- Commentary/fiqh essays attached to Duas.
- Replacing the Prayer Calendar or current-prayer calculations.
