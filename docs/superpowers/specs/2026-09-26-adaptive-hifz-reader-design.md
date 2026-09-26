# Quran Hifz — Adaptive Mushaf Reader Design

Date: 2026-09-26
Status: Approved design

## Goal

Redesign the Hifz Quran reading experience so it feels like a calm Madani Mushaf while remaining genuinely readable on a phone.

The reader must preserve Quran page identity, Surah transitions, Bismillah, ayah markers, Juz/Hizb context, Hifz selection state, audio repetition, and word/ayah interaction. It must not force all content into a fixed 15-line viewport when the user increases Quran text size.

The visual direction combines:

- a warm, quiet Mushaf-like surface;
- adaptive Quran text that can grow without becoming cramped;
- stable 604-page anchors for Hifz spatial memory;
- minimal app chrome;
- compact Hifz audio controls;
- repetition-first memorization workflow.

The design takes inspiration from physical Madani Mushaf reading and modern Hifz applications such as Sahab Hifz, without copying their branding, artwork, or proprietary ornamental assets.

## Core principle

The page number remains stable; the screen height does not.

A Quran page is a logical Hifz anchor, not a requirement that exactly 15 rendered lines fit inside one phone viewport.

At normal text size, the reading section should visually resemble a Mushaf page. At larger text sizes, the same Quran content is allowed to reflow vertically and the section becomes taller.

The reader must never:

- shrink Quran text merely to preserve 15 rows;
- create horizontal scrolling;
- stretch Arabic words into visibly unnatural spacing;
- clip diacritics;
- split the Quran into disconnected ayah cards;
- lose page, Surah, or Juz/Hizb context when font size changes.

## Rendering strategy

### Shared Quran Foundation font catalog

Quran mode and Hifz mode expose the same supported Quran Arabic font catalog.

The catalog contains only Quran-text fonts intentionally retained from Quran Foundation-supported rendering paths:

1. **QPC Hafs / Uthmani** — scalable Unicode. Uses verified `text_qpc_hafs`.
2. **IndoPak Nastaleeq** — scalable Unicode. Uses verified `text_indopak`.
3. **QCF V2 Madani** — page-specific glyph font for strict/pixel-faithful Madani rendering.
4. **QCF V4 Tajweed** — page-specific Tajweed glyph font for strict Tajweed Mushaf rendering.

QPC Hafs / Uthmani is the default for the new adaptive Hifz reader.

The selector must always pair the correct Quran text representation with the selected font. It must never render Uthmani source text through an IndoPak face or IndoPak source text through an Uthmani face.

QPC Hafs and IndoPak are adaptive/free-flow capable. They can enlarge and wrap naturally.

QCF V2 and QCF V4 Tajweed are page-specific rendering choices. They remain visible in the shared catalog, but selecting them uses the compatible strict Mushaf/page renderer rather than pretending they are free-flow Unicode fonts.

### Independent Quran and Hifz preferences

The shared catalog does **not** mean shared settings.

Quran mode persists its own:

- selected Quran font;
- Quran font size;
- Quran line spacing / typography style;
- Quran reading layout style;
- Tajweed-related rendering preference where applicable.

Hifz mode persists its own:

- selected Hifz Quran font;
- Hifz Quran font size;
- Hifz line spacing / typography style;
- Hifz reading layout style;
- Hifz-specific adaptive/strict rendering choice implied by the selected font.

Changing a Quran-mode font or size must not change Hifz. Changing a Hifz font or size must not change the normal Quran reader.

### Remove legacy/unused Quran font choices

The user-facing Quran font selectors should no longer expose legacy or duplicate font choices that are outside the final Quran Foundation-backed catalog.

Remove or hide obsolete user-selectable entries such as:

- PDMS Saleem;
- Al Qalam Quran Majeed;
- Muhammadi Quran;
- Noto Naskh Arabic as a user-selectable Quran face;
- old DigitalKhatt user-facing entries;
- any duplicate/fallback-only font option not part of the final four-font catalog.

A technical fallback font may remain internally only if required for platform safety, but it must not appear as a Quran-font choice.

SurahNameV4 and the dedicated Bismillah glyph/font are presentation assets, not Quran body-font choices, so they remain outside this catalog.

### Quran text flow

Each logical Quran page renders as one continuous RTL Quran text flow.

Ayah markers remain inline with the Quran text.

Ayahs must not become separate card rows or separate paragraphs unless the source layout explicitly requires a Surah boundary.

Normal text should use balanced line wrapping and natural Arabic spacing. Large-text mode must prioritize readable shaping over strict printed-page line boundaries.

The renderer may use the project's canonical Quran page metadata to determine which ayahs/words belong to each logical page.

### Text sizing

The default Hifz Quran size should be noticeably more readable than a literal 15-line page compressed into a phone viewport.

Initial target ranges:

- default: approximately 30–32 logical px;
- comfortable-large: approximately 34–36 logical px;
- large: approximately 38–40 logical px.

These are Hifz-mode design targets, not shared Quran-reader defaults. Quran mode keeps its own independent size scale and layout styling.

For adaptive fonts, the renderer may apply small script-specific metric compensation so QPC Hafs and IndoPak have comparable perceived size at the same Hifz size setting. Switching between them must not make the Quran suddenly appear dramatically smaller or larger.

Line height should be font-relative and generous enough that stacked Quran diacritics never collide. Initial Hifz target is approximately 1.8–2.0 times font size, adjusted independently after real-device measurement for QPC Hafs and IndoPak.

Page-specific QCF V2/QCF V4 rendering follows its own page-renderer sizing rules rather than reusing the free-flow line-height formula.

The final implementation must use rendered measurements rather than assuming that one numeric size behaves identically across fonts, renderers, Android text-scale settings, or Quran/Hifz modes.

## Page structure

The page should read as one coherent Mushaf section.

A typical section contains:

1. optional Quran text continuing from the previous Surah;
2. Surah transition block if a new Surah begins on this page;
3. Bismillah where canonically applicable;
4. continuous Quran text;
5. subtle page metadata footer.

The logical page anchor remains the canonical 1–604 page number even if the rendered section is taller than one screen.

### Page header

The persistent app header is minimal.

Preferred structure:

- centered calligraphic/current Surah name;
- small secondary label such as Surah number or English/Bangla name;
- back/navigation control;
- one compact appearance/action control.

The Quran text must remain the visual focus.

### Surah transition

A new Surah beginning within a page uses a centered divider that feels Quranic but restrained.

Requirements:

- visually distinct from normal Quran text;
- does not dominate the page;
- uses the existing calligraphic Surah-name resource where appropriate;
- keeps enough vertical breathing room before and after;
- remains stable when Quran text size changes.

Avoid copying Sahab's specific ornamentation.

### Bismillah

Bismillah is centered beneath the Surah divider.

Existing canonical rules remain:

- Al-Fatihah must not receive a duplicate standalone Bismillah;
- At-Tawbah must not receive a standalone Bismillah;
- other applicable Surahs receive it once.

The existing QPC V4 Bismillah glyph asset may be used if it visually matches the adaptive page. It must remain centered and must not cause surrounding Quran text to reflow incorrectly.

## Page metadata

Each logical page should retain compact Hifz anchors such as:

- Juz number;
- Hizb / quarter-Hizb where available;
- page number.

Example:

`Juz 22 · ¾ Hizb 44                         Page 440`

The metadata footer is deliberately subtle. It is a memory anchor, not a toolbar.

When the next logical page begins, a small divider/page marker may appear so a large-text user can still tell that Page 440 ended and Page 441 began.

## Scroll behavior

The adaptive reader is vertically scrollable.

Scrolling should feel like moving through a continuous Mushaf, not through independent cards.

When the user changes font size:

- preserve the current ayah/word anchor whenever possible;
- do not jump to the top of the Surah;
- recalculate layout around the same logical content position.

Page boundaries stay deterministic even though physical screen positions change.

## Hifz interaction

### Word and ayah interaction

Existing word tap, long-press, ayah tap, audio-follow, and memorization selection behavior should be preserved.

Interactive regions must not require visible borders or buttons around every word.

### Active audio state

During playback:

- current ayah receives a soft warm highlight;
- current word may receive a slightly stronger highlight;
- highlight must not change line metrics;
- avoid solid high-saturation boxes around Quran text.

### Hifz range

Selected Hifz range should use a subtle treatment, such as a soft underline or low-opacity background.

Selection styling must not make the Quran resemble an editor.

### Hide/reveal

Hide/reveal remains a Hifz practice feature.

The control belongs in the compact Hifz control layer, not permanently inside the Quran text.

The hidden state must retain enough stable markers that the learner does not lose page/ayah context.

## Hifz repetition model

The approved Hifz pattern has **three independent repetition settings**:

1. **New ayah repeat** — how many times each newly introduced ayah plays alone.
2. **Accumulated revision** — after a new ayah is introduced, how many times the range from the selection start through that ayah plays together.
3. **Final full range** — how many times the complete selected range plays after all progressive steps finish.

Each selector offers:

- `1×`
- `2×`
- `3×`
- `4×`
- `5×`

These values mean **repetition count**, not audio playback speed.

Hifz audio playback itself remains at normal 1.0× speed in this flow.

The existing progressive defaults are retained:

- new ayah repeat: **5×**;
- accumulated revision: **3×**;
- final full range: **3×**.

### Progressive build sequence

For a selected range, the memorization sequence grows cumulatively.

Example for ayahs 1–3 with the default 5× / 3× / 3× pattern:

1. Ayah 1 × 5
2. Ayah 2 × 5
3. Ayahs 1–2 together × 3
4. Ayah 3 × 5
5. Ayahs 1–3 together × 3
6. final full selected range 1–3 × 3

Accumulated revision begins only after at least two ayahs are present. There is no redundant `1–1` accumulated-range phase after the first ayah.

The final full-range phase is intentionally a distinct Hifz review phase, even when its range matches the last accumulated range. Its repeat count is independently configurable.

For a longer selected range, the same pattern continues:

- play each new ayah alone using the new-ayah repeat count;
- once at least two ayahs are present, play the accumulated range from selection start through the newest ayah using the accumulated-review count;
- continue until selection end;
- play the complete selected range using the final-full-range count.

For a one-ayah selection, play the single ayah using the new-ayah repeat count, then apply the final-full-range phase only if the existing session/preset contract explicitly includes it for that selection. The implementation must follow one deterministic rule covered by tests and must not accidentally insert an accumulated `1–1` phase.

### Existing sequence compatibility

The project already contains the exact three-field model required by this design:

- `ayahRepeatCount`;
- `combinedRepeatCount`;
- `finalRangeRepeatCount`.

It also already contains the progressive sequence builder, repeat counters, and session progression.

Implementation must preserve and refine that existing domain logic rather than create a second independent audio-loop engine.

## Compact Hifz player

The player remains visually compact so it does not obscure Quran text.

Collapsed state should show:

- play/pause;
- current ayah or current cumulative range;
- repeat progress such as `Repeat 2/3`;
- a compact Hifz-pattern summary such as `New 5× · Build 3× · Final 3×`;
- small progress indicator for the current Hifz sequence.

The full three-stage repeat controls belong in the expandable Hifz pattern sheet rather than permanently consuming Quran reading space.

Every repeat control must clearly communicate repetition through Bangla/English labeling and accessibility text. It must never be labeled or announced as playback speed.

### Expanded controls

A compact expandable sheet may expose:

- selected range;
- reciter;
- pause-between-repeats;
- hide/reveal mode;
- new-ayah repeat count (1×–5×);
- accumulated-review repeat count (1×–5×);
- final-full-range repeat count (1×–5×);
- restart current Hifz sequence;
- stop Hifz session.

Do not place all of these controls permanently over the Quran.

## Audio behavior

Audio continues to use the existing Quran audio/Hifz session engine.

Requirements:

- normal 1.0× playback speed;
- independent new/build/final repeat counts, each selectable from 1× through 5×;
- current repeat index visible;
- current sequence phase/step visible;
- pause/resume preserves the current repeat and step;
- stopping clears the active Hifz playback state cleanly;
- changing the Hifz pattern applies predictably to the active/new sequence, with behavior covered by tests.

If the current engine cannot safely mutate pattern counts mid-step, the UI should apply the new pattern beginning with the next sequence start rather than corrupt current progression.

## Offline behavior

The adaptive reader must use bundled Quran text/page metadata already available locally.

Basic Hifz reading, font rendering, page anchors, Surah boundaries, Bismillah, and repetition sequencing must not require a network request.

Audio availability continues to follow the project's existing recitation/audio caching behavior.

## Accessibility

- Quran text respects the app's Hifz font-size setting.
- App chrome should not scale so aggressively that it crowds out Quran text.
- All player controls need semantic labels.
- Repeat buttons must announce their stage plus count, for example “new ayah, repeat five times” or “final full range, repeat three times,” not ambiguous `3×` alone.
- Current ayah highlighting cannot be the only indication of playback state.
- Contrast must remain sufficient in light/sepia/dark themes if those themes are retained.

## Visual direction

Primary visual tone:

- warm ivory outer background;
- near-white Quran surface;
- black/dark Quran text;
- muted gold/stone ayah and metadata accents;
- restrained green/teal interaction accent consistent with the app;
- rounded page surface;
- minimal ornamentation;
- no heavy cards between ayahs.

The screen should feel closer to a premium physical Mushaf than a dashboard.

### UI typography

The Hifz screen uses separate font families by content type:

- Quran Arabic: the same shared Quran Foundation-backed catalog exposed in Quran mode, with Hifz keeping its own independent selection and sizing.
- Bangla UI: **SolaimanLipi**.
- English UI: Inter.
- Surah calligraphy: existing SurahNameV4 asset.
- Bismillah: existing QPC V4 Bismillah glyph/font.

SolaimanLipi applies to Bangla headings, labels, helper text, pattern descriptions, Hifz progress text, dialogs, sheets, and Bangla metadata. It must not be used for Quran Arabic.

Initial Bangla UI sizing targets:

- sheet/page heading: 22–24 logical px;
- section heading: 17–18 logical px;
- primary label/body: 15–16 logical px;
- helper/secondary text: 13–14 logical px;
- compact metadata: 11–12 logical px.

These values are starting targets and must be checked on the real Android device because SolaimanLipi has different visual density and vertical metrics from Inter.

## Current architecture to preserve

The current project already provides useful pieces that should be reused where possible:

- canonical 604-page metadata;
- Hifz page/session state;
- Hifz sequence builder;
- Quran audio controller with repeat progress;
- word and ayah interaction;
- Surah-name font;
- Bismillah font/glyph;
- existing Hifz settings;
- WebView/Flutter Mushaf rendering experiments.

The redesign should replace the strict fixed-height/15-row presentation constraint, not discard the underlying Hifz domain model.

## Recommended implementation boundary

Introduce an adaptive Hifz Quran surface separate from the strict fixed-page renderer.

The adaptive surface owns:

- logical page grouping;
- Quran text flow;
- page/surah/Bismillah anchors;
- font size and line-height adaptation;
- active/selected Quran text styling.

The Hifz session/audio layer owns:

- sequence generation;
- repeat count;
- current step/repeat;
- play/pause/stop;
- current ayah/range state.

The compact player only renders state and sends user intents.

This separation prevents typography/layout changes from affecting Hifz sequence correctness.

## Testing requirements

### Sequence tests

For each stage, verify all repeat choices `1×`, `2×`, `3×`, `4×`, and `5×`.

Cover:

- new-ayah repeat count independently controls each single-ayah step;
- accumulated-review count independently controls cumulative range steps;
- accumulated revision starts only after the second ayah;
- final-full-range count independently controls the final review phase;
- the default 5× / 3× / 3× pattern produces the approved progressive sequence;
- one-ayah selection never creates an accidental accumulated `1–1` phase;
- pause/resume preserves repeat position;
- stop resets active Hifz playback cleanly.

### Font/settings and layout tests

Verify:

- Quran mode and Hifz mode expose the same final four-font Quran catalog;
- changing Quran-mode font/size/style does not mutate Hifz preferences;
- changing Hifz font/size/style does not mutate Quran-reader preferences;
- legacy/unused Quran font choices are absent from both user-facing selectors;
- page-specific QCF choices route to compatible strict rendering while QPC Hafs/IndoPak remain adaptive/free-flow capable;
- canonical page identity remains stable at multiple Hifz font sizes;
- switching Uthmani/Madani ↔ IndoPak preserves the same logical ayah/page anchor;
- each script uses its matching verified Quran text field and font family;
- Surah transition stays between the correct Quran words/ayahs;
- Bismillah rules remain correct;
- no horizontal overflow at supported phone widths;
- large text causes vertical growth/reflow instead of text shrinking;
- active-word/ayah styling does not alter measured line height;
- page footer belongs to the correct logical page.

### Real-device checks

On the connected Android device verify at minimum:

- small/default/large Hifz font sizes in both Uthmani/Madani and IndoPak;
- script switching at the same visible ayah without losing position;
- Surah transition page such as page 440;
- long ayahs;
- page-to-page scrolling;
- same four-font catalog visible in Quran and Hifz settings;
- Quran and Hifz font-size changes remain independent;
- all three repeat-stage selectors across 1×–5×;
- active audio highlighting;
- hide/reveal;
- orientation/font-scale behavior if supported.

## Acceptance criteria

The redesign is complete when:

1. The Hifz reader visually feels like a coherent Mushaf rather than a list of ayah cards.
2. Default Quran text is comfortably readable on a phone.
3. Increasing text size never forces ugly compression or horizontal scrolling.
4. Quran mode and Hifz mode expose the same final Quran Foundation-backed font catalog while preserving independent font/size/style settings.
5. Legacy and unused Quran font choices are removed from user-facing selectors.
6. Uthmani/Madani and IndoPak render from their verified matching Quran text fields and preserve reading position when switched.
7. Logical 604-page anchors remain visible and correct.
8. Surah and Bismillah transitions remain canonical.
9. Hifz exposes three independent repeat stages, each selectable from `1×` through `5×`.
10. Those values control repetition count, not playback speed.
11. Progressive cumulative repetition follows the approved three-stage sequence model.
12. Existing Hifz word/ayah/audio/session functionality is preserved.
13. Core reading and repetition behavior work offline except where audio itself requires uncached remote media.

## Visual prototype reference

Magic Patterns inspiration canvas:

`https://www.magicpatterns.com/inspiration/236bad9a-5a0c-4b37-8866-0c05bcb2d200`

The preferred direction is a combination of:

- Adaptive Mushaf
- Hifz Focus + Audio

The automatic Magic Patterns AI generator was unavailable because the connected account had insufficient generation credits, so the research comparison was represented through a manually authored Magic Patterns inspiration canvas instead.
