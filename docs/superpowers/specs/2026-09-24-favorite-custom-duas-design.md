# Favorite and Custom Dua Design

## Goal

Upgrade the existing offline Dua module so the Dua tab opens to the user's Favorite Duas instead of the current Daily Duas feed, and allow users to create, edit, delete, search, and favorite their own custom Dua entries.

The verified bundled catalog remains read-only and religiously curated. User-created entries are stored separately and are always identified as custom/personal content so they cannot be mistaken for authenticated Qur'anic or Hadith material.

The main Home dashboard is unchanged by this feature.

## Product Decisions

- The Dua tab's default feed changes from **Daily Duas / দৈনিক দোয়া** to **Favorite Duas / ফেভারিট দোয়া**.
- The default Favorite feed includes both:
  - favorited verified bundled Duas;
  - favorited user-created custom Duas.
- When no Favorite exists, the default feed explains that the user should add a Dua to Favorites to make it appear there.
- The existing verified catalog remains searchable and browsable by category.
- The current 102-entry verified bundled catalog remains unchanged by user-created content.
- Users can create, edit, delete, search, and favorite custom Duas.
- Custom Duas are shown in a dedicated **Custom Duas / আমার দোয়া** surface within the Dua tab.
- A custom Dua always displays a visible **Custom / ব্যক্তিগত দোয়া** badge or equivalent label.
- Custom Dua text is displayed exactly as entered by the user in both Bangla and English app modes.
- Only surrounding UI labels, buttons, empty states, validation messages, and navigation text are localized.
- A custom Dua contains:
  - Title / নাম;
  - Arabic;
  - Transliteration / উচ্চারণ;
  - Meaning / অর্থ;
  - Reference / সূত্র.
- All five custom content fields are required.
- User-entered reference text is informational only and must not be converted into a Qur'an/Hadith authenticity badge or Sahih/Hasan grading.
- The main Home dashboard and Today's Ayah card remain unchanged.

## Current-State Context

The existing Dua feature already provides:

- a verified read-only bundled catalog;
- category browsing;
- offline search;
- persistent Favorite IDs;
- Bangla/English rendering;
- Dua detail pages;
- a default Daily Duas feed.

Favorites currently persist as stable Dua IDs through the user database settings layer. That mechanism can continue to represent Favorite membership, including namespaced custom IDs.

The user database currently has schema version 9. This feature adds a new user-data table and therefore advances the schema to version 10.

## User Experience

### Dua Tab Default State

Opening the Dua tab with no active search, no selected category, and no explicit custom-only mode shows **Favorite Duas / ফেভারিট দোয়া**.

The default list contains every currently favorited Dua that can be resolved from either:

1. the verified bundled catalog; or
2. the custom Dua repository.

The feed uses the existing vertical Dua card/list presentation so it naturally scrolls with the rest of the page.

If there are no Favorites, show a compact empty state:

Bangla:
> ফেভারিটে দোয়া যোগ করুন—এখানে দেখাবে।

English:
> Add favorite duas to show them here.

The empty state should make the next action obvious without forcing navigation. The existing search field, category controls, and custom-Dua access remain visible.

### Verified Dua Discovery

Changing the default feed must not hide the verified catalog.

The existing search field and category selector continue to expose the bundled Dua library. Selecting a category or entering a search query switches from the default Favorite feed to matching results.

The current Favorites filter chip is removed because Favorites are now the default state. This avoids two controls that lead to the same feed.

### Custom Duas Entry Point

Add a compact **Add Dua / দোয়া যোগ করুন** icon action in the Dua page app bar with a localized tooltip.

Replace the old Favorites filter chip with a **Custom Duas / আমার দোয়া** filter chip in the existing filter row. Selecting it opens the user's custom collection.

The custom collection:

- lists all saved custom Duas;
- supports the same Favorite heart action;
- supports opening details;
- exposes edit and delete actions;
- is searchable through the existing Dua search experience.

### Create Custom Dua

The Add Dua action opens a dedicated form page or full-height sheet using existing Material 3 patterns.

Fields:

1. **Title / নাম**
   - single-line;
   - required.
2. **Arabic**
   - multiline;
   - RTL presentation;
   - required.
3. **Transliteration / উচ্চারণ**
   - multiline when necessary;
   - required.
4. **Meaning / অর্থ**
   - multiline;
   - required.
5. **Reference / সূত্র**
   - multiline or single-line depending on layout;
   - required.

The form does not attempt to infer language, translate content, verify the reference, or classify the source.

Whitespace around field values is trimmed for storage, but the user's actual spelling, wording, punctuation, and script are otherwise preserved.

On successful save:

- the custom Dua is persisted locally;
- it appears immediately in Custom Duas;
- it becomes searchable immediately;
- it is not automatically favorited unless the user explicitly favorites it.

### Edit Custom Dua

A custom Dua can be edited from its detail/card actions.

The edit form is the same form used for creation and is pre-populated with the current values.

Saving an edit:

- preserves the stable custom ID;
- updates the content;
- updates the modification timestamp;
- preserves Favorite membership;
- immediately refreshes any visible custom/search/Favorite view.

### Delete Custom Dua

Delete requires a confirmation dialog because the operation is destructive.

Deleting a custom Dua:

- permanently removes its custom record;
- removes its ID from Favorites if present;
- removes it from the default Favorite feed immediately;
- removes it from search and Custom Duas immediately.

The implementation must prevent stale/orphan custom Favorite IDs after a successful delete.

### Custom Dua Detail

Custom Dua detail follows the same readability principles as verified Dua detail but does not use verified-source components.

Display order:

1. Title
2. Custom / ব্যক্তিগত দোয়া badge
3. Arabic
4. Transliteration / উচ্চারণ
5. Meaning / অর্থ
6. Reference / সূত্র
7. Edit/Delete actions where appropriate

The exact user-entered content is shown regardless of app language.

## Religious-Content Boundary

This boundary is a release requirement.

### Verified Bundled Duas

Verified entries continue to use the existing immutable `Dua` model and bundled JSON source. They may carry:

- Qur'an Surah/Ayah metadata;
- Hadith collection/reference;
- Sahih/Hasan grading;
- curated Bangla and English content;
- verified categories/tags.

### Custom Duas

User-created entries use a separate `CustomDua` domain model and separate persistence.

Custom entries:

- are not added to `assets/dua/duas_v1.json`;
- do not become part of the verified catalog count;
- do not receive `DuaSourceType.quran` or `DuaSourceType.hadith`;
- do not receive `HadithGrade.sahih` or `HadithGrade.hasan`;
- do not display the verified-source iconography/labels;
- always display a clear Custom/Personal label.

The user's Reference field is rendered as user-provided reference text only.

## Architecture

Keep the feature under the existing:

`lib/features/dua/`

Add focused units instead of overloading the bundled repository.

Suggested additions:

- `domain/custom_dua.dart`
- `domain/custom_dua_repository.dart`
- `data/drift_custom_dua_repository.dart`
- custom-Dua providers/controllers in `application/dua_providers.dart` or a dedicated `application/custom_dua_providers.dart` if separation improves clarity
- `presentation/custom_dua_form_page.dart`
- custom detail/actions integrated with existing presentation widgets where practical

Existing verified files remain responsible for verified content only.

### CustomDua Model

A custom Dua contains:

- `id`: stable namespaced string ID;
- `title`;
- `arabic`;
- `transliteration`;
- `meaning`;
- `reference`;
- `createdAt`;
- `updatedAt`.

The model intentionally has no Bangla/English duplicate fields. One user-entered value is displayed in either app language.

### Custom IDs

Custom IDs must be stable and collision-proof relative to bundled IDs.

Use a reserved namespace such as:

`custom:<unique-token>`

Requirements:

- generated once at creation;
- preserved across edits;
- never derived from list position;
- never silently reused after deletion;
- impossible to collide with bundled catalog IDs by construction.

The implementation may use UUID-style random IDs or another robust locally generated unique token without requiring network access.

### Shared Display Shape

The verified `Dua` model and `CustomDua` model should remain distinct.

Presentation/search code may use a small shared display abstraction or adapter that exposes only what both kinds need, such as:

- stable ID;
- title;
- Arabic;
- transliteration/pronunciation;
- meaning;
- source/reference display text;
- entry kind: verified or custom.

This adapter must not make custom content look verified. Verified-only source/grading metadata remains accessible only for verified entries.

## Persistence

### New Drift Table

Add a dedicated user-data table such as `CustomDuas`.

Columns:

- `id` TEXT primary key;
- `title` TEXT not null;
- `arabic` TEXT not null;
- `transliteration` TEXT not null;
- `meaning` TEXT not null;
- `reference` TEXT not null;
- `createdAt` DateTime not null;
- `updatedAt` DateTime not null.

No verified source metadata is stored in this table.

### Schema Migration

Advance `UserDatabase.schemaVersion` from 9 to 10.

Migration rule:

- if `from < 10`, create `customDuas`.

The migration is additive only. It must not alter or drop existing user tables or settings.

Existing v1-through-v9 database migration coverage must continue to pass.

### CustomDuaRepository

The repository interface supports:

- list all custom Duas;
- get by ID;
- create;
- update;
- delete.

The Drift implementation owns database mapping and deterministic list ordering.

Recommended list ordering:

- most recently updated first;
- tie-break by stable ID.

This gives immediate visibility to newly created or edited entries without requiring an additional user-defined sort field.

## Favorites Integration

The existing Favorite-ID repository remains the source of Favorite membership.

Verified IDs and namespaced custom IDs share the same Favorite ID set.

### Resolution

A provider builds the combined resolvable collection from:

- bundled verified catalog;
- persisted custom Dua list.

The default Favorite feed:

1. loads Favorite IDs;
2. resolves each ID against the combined collection;
3. ignores unknown IDs safely;
4. returns only resolved entries.

Ordering must be deterministic. Use:

- verified entries in their existing catalog order;
- custom entries in repository order after verified entries;

unless the implementation plan identifies an existing stable ordering primitive that better preserves current UX without adding new persistence.

Favorite membership must update the visible feed immediately.

### Delete Cleanup

Deleting a custom Dua is an application-level operation that coordinates:

1. custom repository delete;
2. Favorite ID cleanup;
3. provider invalidation/state update.

The operation should leave no visible stale entry. If one persistence step fails, the UI must report failure rather than pretending deletion fully succeeded.

## Search

Custom Duas participate in the existing offline Dua search.

Searchable custom fields:

- title;
- Arabic;
- transliteration;
- meaning;
- reference.

Verified entries continue to use their current richer search fields.

Search normalization should reuse the existing Dua normalization logic where possible, including:

- case folding for Latin text;
- whitespace/punctuation normalization;
- Bangla/ASCII digit normalization.

Search results may contain both verified and custom entries.

Each result must retain clear entry-kind labeling so custom content is never visually confused with verified content.

## Filtering and Default-Mode Rules

Define the page state explicitly to avoid ambiguous UI behavior.

### Default Mode

Default mode means:

- search query is empty;
- no verified category is selected;
- Custom Duas mode is not selected.

Default mode shows Favorite Duas.

### Verified Category Mode

Selecting a verified category shows matching verified catalog entries only. Custom entries are excluded because this feature does not add categories to custom Duas.

### Custom Mode

Selecting Custom Duas shows all custom entries, independent of Favorite state.

If a search query is entered while Custom mode is active, search is restricted to custom entries.

### Search Mode

Entering a search query with no selected category and with Custom mode off searches across both verified and custom content.

If a verified category is selected, the query searches only verified entries inside that category. Custom entries are never silently assigned to verified categories.

## Validation and Error Handling

### Form Validation

All five custom fields are required after trimming.

Validation errors are localized and shown adjacent to or directly associated with the relevant field.

The save action must not write partial records.

### Repository Errors

Create/edit/delete errors show a concise localized SnackBar or equivalent error surface and leave the user on a recoverable screen.

### Load Errors

If custom entries fail to load:

- the verified catalog should remain usable where possible;
- Custom Duas surfaces show a retry/error state;
- the app must not silently discard stored custom content.

### Favorite Resolution

Unknown Favorite IDs are ignored rather than converted into fake rows.

Custom deletion proactively removes its Favorite ID, while legacy orphan IDs remain harmless.

## Theming, Layout, and Accessibility

- Use `Theme.of(context).colorScheme`; no hard-coded brand colors.
- Preserve current light, dark, green, and women-theme behavior.
- Keep the Dua screen compact at 360px width.
- Support elevated system text scaling without overflow.
- Arabic input/display is RTL and uses the existing Arabic-capable font where appropriate.
- Form fields have explicit labels and accessible semantics.
- Favorite state is communicated by icon semantics, not color alone.
- Edit/Delete actions have tooltips/semantic labels.
- Delete confirmation clearly names the destructive action.
- Custom/Personal status must be perceivable through text, not color alone.

## State and Data Flow

### App Startup / Dua Page Open

1. Verified bundled catalog loads as it does today.
2. Custom repository loads saved custom entries.
3. Favorite IDs load from the existing Favorite repository.
4. A combined display provider resolves verified and custom entries.
5. The default page derives Favorite entries from the combined collection.

### Create

1. User opens Add Dua.
2. Form validates all required fields.
3. Controller generates a namespaced stable ID.
4. Repository inserts the custom record.
5. Custom/combined/search providers refresh.
6. The new custom Dua appears in Custom Duas.

### Favorite

1. User taps the heart on either verified or custom content.
2. Existing Favorite controller toggles the stable ID.
3. Default Favorite feed updates immediately.

### Edit

1. User opens Edit on a custom Dua.
2. Existing values populate the form.
3. Save validates fields.
4. Repository updates content while preserving ID and created timestamp.
5. Updated timestamp changes.
6. Relevant providers refresh.
7. Existing Favorite membership remains unchanged.

### Delete

1. User requests delete.
2. Confirmation dialog appears.
3. On confirmation, application service/controller deletes the custom record and removes its Favorite ID if present.
4. Providers refresh.
5. The entry disappears from Custom, Search, and Favorite surfaces.

## Files Expected to Change

Likely production files:

- `lib/core/database/user_database.dart`
- generated Drift file after schema update
- `lib/features/dua/domain/custom_dua.dart`
- `lib/features/dua/domain/custom_dua_repository.dart`
- `lib/features/dua/data/drift_custom_dua_repository.dart`
- `lib/features/dua/application/dua_providers.dart` and/or a dedicated custom provider file
- `lib/features/dua/presentation/dua_page.dart`
- `lib/features/dua/presentation/dua_detail_page.dart` only if shared detail routing is appropriate
- `lib/features/dua/presentation/custom_dua_form_page.dart`
- `lib/features/dua/presentation/widgets/dua_card.dart` or a shared card adapter/widget

Likely tests:

- user database migration test;
- custom Dua repository CRUD test;
- Dua providers integration tests;
- Dua page/default Favorite feed tests;
- custom Dua form tests;
- custom search tests;
- localization/content-preservation tests;
- responsive/text-scaling tests.

The implementation plan may refine file boundaries after another read-only inspection, but it must preserve the architecture and behavior defined here.

## Testing Strategy

Implementation follows strict TDD: failing test first, then minimal production implementation.

### Database and Repository Tests

Prove:

- v9 to v10 migration creates `custom_duas` without data loss;
- existing older migration path still reaches current schema;
- create persists all five fields and timestamps;
- reopened database loads created content;
- edit preserves ID and created timestamp while updating content/updated timestamp;
- delete removes the record;
- deterministic list ordering works;
- namespaced IDs do not collide with bundled IDs.

### Provider / Application Tests

Prove:

- default Favorite provider resolves verified favorites;
- default Favorite provider resolves custom favorites;
- combined favorites contain both types;
- unknown Favorite IDs are ignored;
- toggling a custom Favorite persists through the existing Favorite store;
- deleting a favorited custom Dua removes its Favorite ID;
- edit preserves Favorite membership;
- create does not auto-favorite.

### Search Tests

Prove custom search matches:

- title;
- Arabic;
- transliteration;
- meaning;
- reference.

Also prove existing verified search behavior remains intact.

### Presentation Tests

Prove:

- default Dua tab heading is Favorite Duas / ফেভারিট দোয়া;
- no Favorites shows the new instructional empty state;
- favoriting a verified entry makes it appear in the default feed;
- favoriting a custom entry makes it appear in the same default feed;
- Custom Duas mode lists saved custom content;
- Add Dua form contains all five fields;
- whitespace-only required values are rejected;
- save creates and displays the custom Dua;
- edit pre-populates and updates fields;
- delete requires confirmation and removes the entry;
- custom card/detail visibly says Custom / ব্যক্তিগত দোয়া;
- switching Bangla/English app mode does not alter user-entered custom content;
- verified Dua cards/details retain their existing verified source labels.

### Regression and Device Verification

After focused tests:

1. run `flutter analyze`;
2. run full `flutter test`;
3. build debug APK;
4. install on the OPPO CPH2179 via Wi-Fi ADB;
5. visually verify on the real device:
   - empty Favorite default state;
   - favorite verified Dua -> default feed;
   - create custom Dua;
   - custom content is unchanged between Bangla/English modes;
   - favorite custom Dua -> default feed;
   - edit custom Dua;
   - delete custom Dua;
   - deleted custom entry is also absent from Favorites;
   - 360px-width layout remains compact and readable.

## Non-Goals

This feature does not add:

- cloud sync;
- custom Dua sharing/export;
- audio recording or playback for custom Duas;
- automatic transliteration;
- automatic translation;
- automatic authenticity verification;
- AI-generated Dua content;
- custom categories/tags;
- attachment/images;
- import from clipboard beyond normal text-field paste;
- reordering Favorites;
- modifications to the main Home dashboard;
- changes to the verified 102-Dua bundled catalog.

## Acceptance Criteria

The feature is complete when:

1. Opening Dua with no search/filter shows Favorite Duas instead of Daily Duas.
2. No Favorites shows the approved instructional empty state.
3. Favorite verified Duas appear in the default feed.
4. Users can create a custom Dua with Title, Arabic, Transliteration, Meaning, and Reference.
5. Custom content displays exactly as entered in both app languages.
6. Custom entries are clearly labeled Custom/Personal and never appear authenticated.
7. Users can edit and delete custom entries.
8. Users can favorite custom entries and see them in the same default Favorite feed as verified entries.
9. Custom entries are searchable by all five entered fields.
10. Deleting a favorited custom Dua removes its Favorite membership.
11. Custom Duas persist across app/database restart.
12. Existing verified-catalog validation and authenticity tests remain green.
13. Existing search/category behavior remains available.
14. Main Home dashboard remains unchanged.
15. Full static analysis, full test suite, APK build, install, and real-device verification all pass.
